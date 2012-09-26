# -*- coding: utf-8 -*-
require 'fileutils'
require 'grit'

module GitPusher
  class Runner
    def self.run
      context = Context.instance

      src_repos = src.repos
      num_per_process = src_repos.length / context.processes
      num_per_process += 1 unless src_repos.length % context.processes == 0
      FileUtils::Verbose.mkpath base_dir unless File.directory? base_dir
      Dir.chdir(base_dir) do
        src_repos.each_slice(num_per_process) do |repos|
          fork do
            repos.each do |src_repo|
              mirror src_repo
            end
          end
        end
      end

      Process.waitall
    end

    def self.mirror(src_repo)
      repo_name = File.basename(src_repo.url).gsub(/.git$/, '')
      repo_path = File.join(base_dir, repo_name)
      puts "[#{Process.pid}][#{repo_name}]Cheking #{src_repo.url} ..."
      unless File.exist?(repo_path)
        `git clone #{src_repo.url}`
      end

      local_repo = Grit::Repo.new(repo_path)

      # local repo の git remote で mirror があるかどうかチェック
      has_remote_mirror = false
      local_repo.remote_list.each do |remote|
        has_remote_mirror = true if remote === 'mirror'
      end

      unless has_remote_mirror
        mirror_repo = dest.repo(repo_name) || dest.create_repo(repo_name)
        local_repo.git.remote({}, 'add', 'mirror', mirror_repo.url)
      end

      local_repo.remotes.each do |remote|
        next if remote.name == 'origin/HEAD'
        next if remote.name =~ %r!mirror/.+!
        branch = remote.name.gsub(%r!^origin/!, '')

        matched = false
        local_repo.branches.each do |x|
          matched = true if x.name === branch
        end

        unless matched
          local_repo.git.branch({}, branch, remote.name)
        end

        Dir.chdir(repo_path) do
          local_repo.git.checkout({}, branch)

          # pull する
          puts "[#{Process.pid}][#{repo_name}]Pulling #{branch} ..."
          local_repo.git.pull({ :timeout => 300 }, 'origin', branch)

          # git push mirror #{branch} する
          puts "[#{Process.pid}][#{repo_name}]Pushing #{branch} ..."
          local_repo.git.push({ :timeout => 300 }, 'mirror', branch)
        end
      end
    end

    def self.src
      Service::Factory.create(Context.instance.config[:src])
    end

    def self.dest
      Service::Factory.create(Context.instance.config[:dest])
    end

    def self.base_dir
      Context.instance.config[:base_dir]
    end
  end
end
