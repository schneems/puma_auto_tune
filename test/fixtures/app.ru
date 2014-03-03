require 'rack'
require 'rack/server'

run Proc.new {|env| [200, {}, ['Hello World']] }



require 'puma_auto_tune'

PumaAutoTune.config do |config|
  config.ram       = Integer(ENV['PUMA_RAM'])       if ENV['PUMA_RAM']
  config.frequency = Integer(ENV['PUMA_FREQUENCY']) if ENV['PUMA_FREQUENCY']
end
PumaAutoTune.start
