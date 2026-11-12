# frozen_string_literal: true

require "json"

module OpsGithub
  # Emits OPS_GITHUB_WAKE only when probe reports a delta. Adaptive interval.
  class Watch
    SENTINEL = "OPS_GITHUB_WAKE"

    # +brief_every+: seconds between "/ops brief" wakes; 0 = never. +clock_fn+ is monotonic.
    def initialize(probe:, stdout: $stdout, sleep_fn: nil, clock_fn: nil, brief_every: 0)
      @probe = probe
      @stdout = stdout
      @sleep_fn = sleep_fn || ->(seconds) { sleep(seconds) }
      @clock_fn = clock_fn || -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
      @brief_every = brief_every.to_i
      @quiet_streak = 0
    end

    def run(max_ticks: nil)
      ticks = 0
      @next_brief_at = @clock_fn.call + @brief_every
      loop do
        break if max_ticks && ticks >= max_ticks

        ticks += 1
        status = @probe.call
        if status == CLI::PROBE_DELTA
          @quiet_streak = 0
          emit_wake("changes")
        elsif status == CLI::PROBE_QUIET
          @quiet_streak += 1
        else
          emit_wake("env")
          break if max_ticks && ticks >= max_ticks

          pause(300)
          next
        end

        break if max_ticks && ticks >= max_ticks

        pause(interval_seconds)
      end
    end

    def interval_seconds
      return 180 if @quiet_streak < 2

      # Capped so a review request never waits longer than one quiet interval.
      600
    end

    private

    # Sleeps +seconds+ in total; a brief due inside the pause fires on time and the
    # rest of the pause continues, so probe cadence neither starves nor drifts.
    def pause(seconds)
      return @sleep_fn.call(seconds) unless @brief_every.positive?

      remaining = seconds
      while remaining.positive?
        step = [remaining, [@next_brief_at - @clock_fn.call, 0].max].min
        @sleep_fn.call(step) if step.positive?
        remaining -= step
        next unless @clock_fn.call >= @next_brief_at

        emit_wake("brief", "/ops brief")
        @next_brief_at = @clock_fn.call + @brief_every
      end
    end

    def emit_wake(urgency, prompt = "/ops")
      payload = { "prompt" => prompt, "urgency" => urgency }
      @stdout.write("#{SENTINEL} #{JSON.generate(payload)}\n")
      @stdout.flush if @stdout.respond_to?(:flush)
    end
  end
end
