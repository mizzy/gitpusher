require 'singleton'
module GitPusher
  class Context
    include Singleton
    attr_accessor :home, :config
  end
end
