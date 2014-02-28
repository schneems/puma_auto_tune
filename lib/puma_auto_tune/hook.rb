module PumaAutoTune
  class Hook



    def initialize(memory = PumaAutoTuneMemory.new)
      @memory  = memory
      @started = Time.now
    end

    def set_logger(&block)
      @log = block
    end

    def auto_cycle
      Thread.new do
        loop do
          call(:cycle)
        end
      end
    end

    def log(msg, options = {})
      elapsed = (Time.now - @started).ceil
      msg =  ["PumaAutoTune (#{elapsed}s): #{msg}"]

      options["total_memory_mb"] = @memory.mb
      options["cluster_size"]    = @memory.workers.size
      options.each { |k, v| msg << "puma.#{k.to_s.downcase}=#{v}" }
      puts msg.join(" ")
    end

    def cycle(&block)
      if block
        @cycle = Proc.new {
          loop do
            sleep PumaAutoTune.frequency
            @memory.reset
            block.call(*self.args)
          end
        }
      end
      @cycle
    end

    def reap_cycle(&block)
      if block
        @reap_cycle = Proc.new {
          end_at = Time.now + PumaAutoTune.reap_duration # seconds
          while Time.now < end_at
            @memory.reset
            sleep 1
            block.call(*self.args)
          end
        }
      end
      @reap_cycle
    end


    def under_memory(&block)
      @under_memory = block if block
      @under_memory
    end

    def out_of_memory(&block)
      @out_of_memory = block if block
      @out_of_memory
    end

    def add_worker(&block)
      @add_worker = block if block
      @add_worker
    end

    def remove_worker(&block)
      if block
        @remove_worker = Proc.new {
            @memory.reset # call before @memory.workers
            PumaAutoTune.max_workers = @memory.workers.size - 1
            block.call(*self.args)
          }
      end
      @remove_worker
    end

    def args
      [@memory.mb, @memory.master, @memory.workers]
    end

    def call(state)
      @memory.reset # clears cache
      case state
      when :cycle
        cycle
      when :reap_cycle
        reap_cycle
      when :under_memory
        under_memory
      when :out_of_memory
        out_of_memory
      when :add_worker
        add_worker
      when :remove_worker
        remove_worker
      else
        raise "not supported: #{state}"
      end.call(*self.args)
    end
  end
end
