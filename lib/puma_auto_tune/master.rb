module PumaAutoTune
  class Master
  def initialize(master = nil)
      @master = master || get_master
    end

    def running?
      @master && workers.any?
    end

    # https://github.com/puma/puma/blob/master/docs/signals.md#puma-signals
    def remove_worker
      previous_worker_count = workers.size
      send_signal("TTOU")
      until workers.size < previous_worker_count
        sleep 0.1
      end
    end

    # https://github.com/puma/puma/blob/master/docs/signals.md#puma-signals
    def add_worker
      send_signal("TTIN")
    end

    # less cryptic interface
    def send_signal(signal, pid = Process.pid)
      Process.kill(signal, pid)
    end

    def memory
      @memory
    end
    alias :mb :memory

    def get_memory
      @memory = ::GetProcessMem.new(Process.pid).mb
    end

    def workers
      @master.instance_variable_get("@workers").
        reject { |w| w.instance_variable_get("@first_term_sent") }.
        map    { |w| PumaAutoTune::Worker.new(w) }
    end

    private

    def get_master
      ObjectSpace.each_object(Puma::Cluster).map { |obj| obj }.first if defined?(Puma::Cluster)
    end
  end
end
