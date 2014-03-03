PumaAutoTune.hooks(:ram) do |auto|
  auto.wrap(:reap_cycle) do |block|
    Proc.new do |resource, master, workers|
      ends_at = Time.now - PumaAutoTune.reap_duration
      while Time.now < ends_at
        sleep 1
        block.call(*auto.args)
      end
    end
  end

  auto.wrap(:remove_worker) do |block|
    Proc.new do |resource, master, workers|
      resource.reset
      PumaAutoTune.max_workers = workers.size - 1
      block.call(*auto.args)
    end
  end
end
