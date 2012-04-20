require 'grit'

module GitPusher
  class Runner
    def self.run
      context = GitPusher::Context.instance

      src  = GitPusher::Service::Factory.create(context.config[:src])
      dest = GitPusher::Service::Factory.create(context.config[:dest])

      base_dir = context.config[:base_dir]
      src.repos.each do |src_repo|
        puts "Cheking #{src_repo.url} ..."
        repo_name = File.basename(src_repo.url).gsub(/.git$/, '')
        repo_path = File.join(base_dir, repo_name)
        unless File.exist?(repo_path)
          Dir.chdir(base_dir) do
            p src_repo.url
            `git clone #{src_repo.url}`
          end
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

          # pull する
          puts "Pulling #{branch} ..."
          local_repo.git.pull({}, 'origin', branch)

          # git push mirror #{branch} する
          puts "Pushing #{branch} ..."
          local_repo.git.push({ :timeout => 300 }, 'mirror', branch)
        end

      end


    end
  end
end
