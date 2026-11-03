# frozen_string_literal: true

require "stringio"
require_relative "test_helper"
require_relative "../src/ops_github/watch"

class WatchTest < Minitest::Test
  def test_emits_wake_only_on_delta
    statuses = [OpsGithub::CLI::PROBE_QUIET, OpsGithub::CLI::PROBE_DELTA, OpsGithub::CLI::PROBE_QUIET]
    out = StringIO.new
    sleeps = []
    watch = OpsGithub::Watch.new(
      probe: -> { statuses.shift || OpsGithub::CLI::PROBE_QUIET },
      stdout: out,
      sleep_fn: ->(s) { sleeps << s }
    )
    watch.run(max_ticks: 3)
    wakes = out.string.lines.select { |l| l.start_with?(OpsGithub::Watch::SENTINEL) }
    assert_equal(1, wakes.size)
    assert_match(/"urgency":"changes"/, wakes.first)
  end

  def test_interval_backs_off_after_quiet_streak
    watch = OpsGithub::Watch.new(probe: -> { OpsGithub::CLI::PROBE_QUIET }, stdout: StringIO.new, sleep_fn: ->(_) {})
    assert_equal(180, watch.interval_seconds)
    watch.instance_variable_set(:@quiet_streak, 2)
    assert_equal(600, watch.interval_seconds)
    watch.instance_variable_set(:@quiet_streak, 4)
    assert_equal(3600, watch.interval_seconds)
  end
end
