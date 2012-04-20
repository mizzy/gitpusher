require 'octokit'
require 'pit'

module GitPusher
  module Repo
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
        octokit.repos(self.organization||self.user).each do |repo|
          p repo
          break
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
