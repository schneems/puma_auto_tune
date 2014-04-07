Bundler.require

require 'test/unit'

class PumaRemote

  attr_accessor :path, :frequency, :reap_duration, :config, :log, :ram, :pid, :puma_workers

  def initialize(options = {})
    @path           = options[:path]         || fixture_path("app.ru")
    @frequency      = options[:frequency]    || 1
    @reap_duration  = options[:reap_duration]
    @config         = options[:config]       || fixture_path("config.rb")
    @log            = options[:log]          || new_log_file
    @ram            = options[:ram]          || 512
    @puma_workers   = options[:puma_workers] || 3
  end

  def wait(regex = %r{booted}, timeout = 30)
    Timeout::timeout(timeout) do
      until log.read.match regex
        sleep 1
      end
    end
    sleep 1
    self
  rescue Timeout::Error
    puts "Timeout waiting for #{regex.inspect} in \n#{log.read}"
    false
  end

  def cleanup
    shutdown
    FileUtils.remove_entry_secure log
  end

  def shutdown
    if pid
      Process.kill('TERM', pid)
      Process.wait(pid)
    end
  rescue Errno::ESRCH
  end

  def spawn
    FileUtils.mkdir_p(log.dirname)
    FileUtils.touch(log)
    env = {}
    env["PUMA_WORKERS"]       = puma_workers
    env["PUMA_FREQUENCY"]     = frequency
    env["PUMA_RAM"]           = ram
    env["PUMA_REAP_DURATION"] = reap_duration
    env_string = env.map {|key, value| "#{key}=#{value}" if value }.join(" ")

    @pid = Process.spawn("exec env #{env_string} bundle exec puma #{path} -C #{config} > #{log}")
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
