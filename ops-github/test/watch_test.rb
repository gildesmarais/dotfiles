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
    assert_equal(%(#{OpsGithub::Watch::SENTINEL} {"prompt":"/ops","urgency":"changes"}\n), wakes.first)
  end

  def timed_watch(brief_every:, out:, sleeps: [])
    now = 0
    OpsGithub::Watch.new(
      probe: -> { OpsGithub::CLI::PROBE_QUIET },
      stdout: out,
      sleep_fn: lambda { |s|
        sleeps << s
        now += s
      },
      clock_fn: -> { now },
      brief_every: brief_every
    )
  end

  def test_brief_every_wakes_on_schedule_without_changing_probe_cadence
    out = StringIO.new
    sleeps = []
    timed_watch(brief_every: 200, out: out, sleeps: sleeps).run(max_ticks: 3)
    # Pauses of 180s then 600s; briefs fall due at t=200, 400, 600 and split the second pause.
    assert_equal([180, 20, 200, 200, 180], sleeps)
    assert_equal(780, sleeps.sum)
    wakes = out.string.lines
    assert_equal(3, wakes.size)
    assert_equal(%(#{OpsGithub::Watch::SENTINEL} {"prompt":"/ops brief","urgency":"brief"}\n), wakes.first)
  end

  def test_brief_every_zero_never_wakes_and_sleeps_whole_intervals
    out = StringIO.new
    sleeps = []
    timed_watch(brief_every: 0, out: out, sleeps: sleeps).run(max_ticks: 3)
    assert_equal([180, 600], sleeps)
    assert_empty(out.string)
  end

  def test_interval_backs_off_after_quiet_streak
    watch = OpsGithub::Watch.new(probe: -> { OpsGithub::CLI::PROBE_QUIET }, stdout: StringIO.new, sleep_fn: ->(_) {})
    assert_equal(180, watch.interval_seconds)
    watch.instance_variable_set(:@quiet_streak, 2)
    assert_equal(600, watch.interval_seconds)
    watch.instance_variable_set(:@quiet_streak, 50)
    assert_equal(600, watch.interval_seconds)
  end
end
