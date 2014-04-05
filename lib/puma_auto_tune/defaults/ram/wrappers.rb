PumaAutoTune.hooks(:ram) do |auto|
  auto.wrap(:reap_cycle) do |orig|
    Proc.new do |resource, master, workers|
      ends_at = Time.now + PumaAutoTune.reap_duration
      while Time.now < ends_at
        sleep 1
        orig.call(*auto.args)
      end
    end
  end

  auto.wrap(:out_of_memory) do |orig|
    Proc.new do |resource, master, workers|
      if PumaAutoTune.max_worker_limit > 1
        orig.call(*auto.args)
      else
        auto.log "Out of memory but cannot have less than one worker, you need more RAM"
      end
    end
  end

  auto.wrap(:remove_worker) do |orig|
    Proc.new do |resource, master, workers|
      if workers.size > 1 && PumaAutoTune.max_worker_limit > 1
        PumaAutoTune.max_worker_limit = workers.size if PumaAutoTune::INFINITY == PumaAutoTune.max_worker_limit
        PumaAutoTune.max_worker_limit -= 1
        orig.call(*auto.args)
      else
        auto.log "Out of memory but cannot have less than one worker, you need more RAM"
      end
    end
  end

  auto.wrap(:cycle) do |orig|
    Proc.new do |resource, master, workers|
      loop do
        sleep PumaAutoTune.frequency
        orig.call(*auto.args) if master.running?
      end
    end
  end
end
