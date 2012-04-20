module GitPusher
  module Repo
    class Factory
      def self.create(config)
        case config[:type]
          when /github/i     then GitPusher::Repo::GitHub.new(config)
          when /bitbucket/i  then GitPusher::Repo::BitBucket.new(config)
          else
            raise "unknown issue tracker type : #{its_type}"
        end
      end
    end
  end
end
