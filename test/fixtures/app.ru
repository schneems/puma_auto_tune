require 'rack'
require 'rack/server'

run Proc.new {|env| [200, {}, ['Hello World']] }



require 'puma_auto_tune'

PumaAutoTune.config do |config|
  config.ram            = Integer(ENV['PUMA_RAM'])          if ENV['PUMA_RAM']
  config.frequency      = Integer(ENV['PUMA_FREQUENCY'])    if ENV['PUMA_FREQUENCY']
  config.reap_duration  = Integer(ENV['PUMA_REAP_DURATION']) if ENV['PUMA_REAP_DURATION']
end
PumaAutoTune.start
