module GitPusher
  module Service
    class Factory
      def self.create(config)
        case config[:type]
          when /github/i     then GitPusher::Service::GitHub.new(config)
          when /bitbucket/i  then GitPusher::Service::BitBucket.new(config)
          else
            raise "unknown issue tracker type : #{its_type}"
        end
      end
    end
  end
end
