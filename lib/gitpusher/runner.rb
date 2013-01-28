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
      repo_path = File.join(base_dir, "#{repo_name}.git")
      unless File.exist?(repo_path)
        puts "[#{Process.pid}][#{repo_name}]Cloning #{src_repo.url} ..."
        `git clone --mirror #{src_repo.url}`
      end

      local_repo = Grit::Repo.new(repo_path)

      has_remote_mirror = false
      local_repo.remote_list.each do |remote|
        has_remote_mirror = true if remote === 'mirror'
      end

      mirror_repo = dest.repo(repo_name) || dest.create_repo(repo_name)
      unless has_remote_mirror
        local_repo.git.remote({}, 'add', 'mirror', mirror_repo.url)
      end

      Dir.chdir(repo_path) do
        puts "[#{Process.pid}][#{repo_name}]Pruning all stale branches of #{repo_name} ..."
        local_repo.git.remote({}, 'prune', 'origin')

        puts "[#{Process.pid}][#{repo_name}]Fetching from #{src_repo.url} ..."
        local_repo.git.fetch({ :timeout => 300 }, 'origin')

        puts "[#{Process.pid}][#{repo_name}]Pushing to #{mirror_repo.url} ..."
        local_repo.git.push({ :timeout => 300 }, 'mirror','--mirror')
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
