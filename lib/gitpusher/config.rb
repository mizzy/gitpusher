require 'yaml'
module GitPusher
  class Config
    def self.load(options)
      context = GitPusher::Context.instance
      context.config = YAML.load_file(File.join(context.home, options[:config]))
    end
  end
end

