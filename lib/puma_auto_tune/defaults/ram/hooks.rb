## This is the default algorithm
PumaAutoTune.hooks(:ram) do |auto|
  # Runs in a continual loop controlled by PumaAutoTune.frequency
  auto.set(:cycle) do |memory, master, workers|
    if memory > PumaAutoTune.ram # mb
      auto.call(:out_of_memory)
    else
      auto.call(:under_memory)
    end
  end

  # Called repeatedly for `PumaAutoTune.reap_duration`.
  # call when you think you may have too many workers
  auto.set(:reap_cycle) do |memory, master, workers|
    if memory > PumaAutoTune.ram
      auto.call(:remove_worker)
    end
  end

  # Called when puma is using too much memory
  auto.set(:out_of_memory) do |memory, master, workers|
    if workers.size > 1
      largest_worker = workers.last # ascending worker size
      auto.log "Potential memory leak. Reaping largest worker", largest_worker_memory_mb: largest_worker.memory
      largest_worker.restart
      auto.call(:reap_cycle)
    else
      auto.log "Out of memory but cannot have less than one worker, you need more RAM"
    end
  end

  # Called when puma is not using all available memory
  # PumaAutoTune.max_workers is tracked automatically by `remove_worker`
  auto.set(:under_memory) do |memory, master, workers|
    theoretical_max_mb = memory + workers.first.memory # ascending worker size
    if (theoretical_max_mb < PumaAutoTune.ram) && (workers.size.next < PumaAutoTune.max_worker_limit)
      auto.call(:add_worker)
    else
      auto.log "All is well"
    end
  end

  # Called to add an extra worker
  auto.set(:add_worker) do |memory, master, workers|
    auto.log "Cluster too small. Resizing to add one more worker"
    master.add_worker
    auto.call(:reap_cycle)
  end

  # Called to remove 1 worker from pool. Sets maximum size
  auto.set(:remove_worker) do |memory, master, workers|
    if workers.size > 1
      PumaAutoTune.max_worker_limit = workers.size - 1
      auto.log "Cluster too large. Resizing to remove one worker"
      master.remove_worker
      auto.call(:reap_cycle)
    else
      auto.log "Out of memory but cannot have less than one worker, you need more RAM"
    end
  end
end
