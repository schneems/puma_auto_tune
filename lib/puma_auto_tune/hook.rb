module PumaAutoTune
  class Hook

    def initialize(resource)
      @resource = resource
      @started  = Time.now
      @hooks    = {}
      @wraps    = {}
    end

    def define_hook(name, &block)
      if wrap = @wraps[name]
        @hooks[name] = wrap.call(block)
      else
        @hooks[name] = block
      end
    end
    alias :set :define_hook

    def call(name)
      hook = @hooks[name] or raise "No such hook #{name.inspect}. Available: #{@hooks.keys.inspect}"
      hook.call(*self.args)
    end

    # define a hook by passing a block
    def wrap_hook(name, &block)
      @wraps[name] = block
    end
    alias :wrap :wrap_hook

    def auto_cycle
      Thread.new do
        self.call(:cycle)
      end
    end

    def log(msg, options = {})
      elapsed = (Time.now - @started).ceil
      msg     = ["PumaAutoTune (#{elapsed}s): #{msg}"]

      options[@resource.name]         = @resource.amount
      options["current_cluster_size"] = @resource.workers.size
      options["max_worker_limit"]     = PumaAutoTune.max_worker_limit
      options.each { |k, v| msg << "measure#puma.#{k.to_s.downcase}=#{v}" }
      puts msg.join(" ")
    end

    def args
      @resource.reset
      [@resource.amount, @resource.master, @resource.workers]
    end
  end
end

require 'puma_auto_tune/defaults/ram/wrappers'
require 'puma_auto_tune/defaults/ram/hooks'
