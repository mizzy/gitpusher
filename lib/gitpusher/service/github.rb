require 'octokit'
require 'pit'

module GitPusher
  module Service
    class GitHub < Base
      attr :user, :password, :organization

      def initialize(config)
        super(config)
        @user     = Pit.get(
          'github', :require => { 'user' => 'Your user name of GitHub' }
        )['user']
        @password = Pit.get(
          'github', :require => { 'password' => 'Your user password of GitHub' }
        )['password']
        @organization = config[:organization]
      end

      def repos
        repos = []
        github_repos = self.organization ? octokit.org_repos(self.organization) : octokit.repos(self.user)
        github_repos.each do |repo|
          repos << GitPusher::Repo.new(repo[:ssh_url])
        end
        repos
      end

      private
      def octokit
        Octokit::Client.new(:login => self.user, :password => self.password)
      end

    end
  end
end
