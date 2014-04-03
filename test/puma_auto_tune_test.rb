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

  def test_cannot_drop_below_one
    @puma = PumaRemote.new(ram: 1, puma_workers: 1).spawn
    @puma.wait
    assert_match "cannot have less than one worker", @puma.log.read
  end

  def test_reap_workers
    @puma = PumaRemote.new(ram: 1, puma_workers: 5).spawn
    @puma.wait

    sleep 5
    assert_match "max_worker_limit=3", @puma.log.read
    assert_match "max_worker_limit=2", @puma.log.read
    # refute
    refute_match "max_worker_limit=0", @puma.log.read
  end

end
