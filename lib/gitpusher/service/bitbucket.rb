require 'open-uri'
require 'net/http'

module GitPusher
  module Service
    class BitBucket < Base

      def initialize(config)
        super(config)
        @user     = Pit.get(
          'bitbucket', :require => { 'user' => 'Your user name of BitBucket' }
        )['user']
        @password = Pit.get(
          'bitbucket', :require => { 'password' => 'Your user password of BitBucket' }
        )['password']
      end

      def repo(name)
        url = sprintf 'https://api.bitbucket.org/1.0/repositories/%s/%s', @user, name
        opt = {"Authorization" => "Basic " + Base64.encode64("#{@user}:#{@password}")}
        opt[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE
        begin
          json = open(url, opt) {|io|
            JSON.parse(io.read)
          }
        rescue OpenURI::HTTPError => e
          if e.message === '404 NOT FOUND'
            return nil
          else
            raise e
          end
        end

        GitPusher::Repo.new(ssh_url(name))
      end

      def create_repo(name)
        puts "Creating repository #{name} on the mirror ..."
        https = Net::HTTP.new('api.bitbucket.org', 443)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.start{|http|
          request = Net::HTTP::Post.new('/1.0/repositories/')
          request.basic_auth @user, @password
          request.set_form_data({
            :name       => name,
            :scm        => 'git',
            :is_private => 'True',
          })
          response = http.request(request)
        }

        GitPusher::Repo.new(ssh_url(name))
      end

      private
      def ssh_url(name)
        sprintf "git@bitbucket.org:%s/%s.git", @user, name
      end

    end
  end
end
