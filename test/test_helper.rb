Bundler.require

require 'test/unit'

class PumaRemote

  attr_accessor :path, :frequency, :config, :log, :ram, :pid, :puma_workers

  def initialize(options = {})
    @path         = options[:path]         || fixture_path("app.ru")
    @frequency    = options[:frequency]    || 1
    @config       = options[:config]       || fixture_path("config.rb")
    @log          = options[:log]          || new_log_file
    @ram          = options[:ram]          || 512
    @puma_workers = options[:puma_workers] || 3
  end

  def wait(regex = %r{booted})
    until log.read.match regex
      sleep 1
    end
    sleep 1
    self
  end

  def shutdown
    if pid
      Process.kill('TERM', pid)
      Process.wait(pid)
    end

    FileUtils.remove_entry_secure log
  end

  def spawn
    FileUtils.mkdir_p(log.dirname)
    FileUtils.touch(log)
    @pid = Process.spawn("exec env PUMA_WORKERS=#{puma_workers} PUMA_FREQUENCY=#{frequency} PUMA_RAM=#{ram} bundle exec puma #{path} -C #{config} > #{log}")
    self
  end

  def new_log_file
    Pathname.new("test/logs/puma_#{rand(1...2000)}_#{Time.now.to_f}.log")
  end

  def fixture_path(name = nil)
    path = Pathname.new(File.expand_path("../fixtures", __FILE__))
    return path.join(name) if name
    path
  end
end
