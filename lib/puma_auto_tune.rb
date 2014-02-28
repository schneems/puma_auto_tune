require 'get_process_mem'

module PumaAutoTune
  INFINITY    = 1/0.0

  extend self

  attr_accessor :ram, :max_workers, :frequency, :reap_duration
  self.ram           = 512  # mb
  self.max_workers   = INFINITY
  self.frequency     = 10 # seconds
  self.reap_duration = 90 # seconds

  def self.hooks(memory = PumaAutoTune::Memory.new, &block)
    @hook ||= Hook.new(memory)
    block.call(@hook) if block
    @hook
  end

  def start
    hooks.auto_cycle
  end
end

require 'puma_auto_tune/version'
require 'puma_auto_tune/master'
require 'puma_auto_tune/worker'
require 'puma_auto_tune/memory'
require 'puma_auto_tune/hook'
require 'puma_auto_tune/default'