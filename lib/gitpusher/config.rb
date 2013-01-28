require 'yaml'
module GitPusher
  class Config
    def self.load(options)
      context = GitPusher::Context.instance
      context.config = YAML.load_file(File.join(options[:config]))
      context.config[:base_dir] = File.expand_path(context.config[:base_dir])
    end
  end
end

