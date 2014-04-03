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

  auto.wrap(:cycle) do |orig|
    Proc.new do |resource, master, workers|
      loop do
        sleep PumaAutoTune.frequency
        orig.call(*auto.args) if master.running?
      end
    end
  end
end
