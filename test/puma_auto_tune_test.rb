require 'test_helper'

class PumaAutoTuneTest < Test::Unit::TestCase

  def teardown
    @puma.shutdown if @puma
  end

  def test_starts
    @puma = PumaRemote.new.spawn
    @puma.wait
    assert_match "PumaAutoTune", @puma.log.read
  end

end
