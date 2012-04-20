module GitPusher
  class Helper

=begin いらないかも
    def self.git_config_value(name, trim = true)
      res = `git config issue.#{name}`
      trim ? res.strip : res
    end

    def self.git_global_config_value(name)
      res = `git config --global #{name}`
      res.strip
    end
=end

  end
end
