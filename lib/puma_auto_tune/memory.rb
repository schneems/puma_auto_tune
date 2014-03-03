require 'delegate'

module PumaAutoTune

  class Memory
    attr_accessor :master, :workers

    def initialize(master = PumaAutoTune::Master.new)
      @master = master
    end

    def name
      "resource_ram_mb"
    end

    def amount
      @mb ||= begin
        worker_memory = workers.map {|w| w.memory }.inject(&:+) || 0
        worker_memory + @master.get_memory
      end
    end

    def largest_worker
      workers.last
    end

    def smallest_worker
      workers.first
    end

    def workers
      workers ||= @master.workers.sort_by! {|w| w.get_memory }
    end

    def reset
      raise "must set master" unless @master
      @workers      = nil
      @mb           = nil
    end
  end
end