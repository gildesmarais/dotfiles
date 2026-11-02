# frozen_string_literal: true

require "json"

module OpsGithub
  # Emits OPS_GITHUB_WAKE only when probe reports a delta. Adaptive interval.
  class Watch
    SENTINEL = "OPS_GITHUB_WAKE"

    def initialize(probe:, stdout: $stdout, sleep_fn: nil)
      @probe = probe
      @stdout = stdout
      @sleep_fn = sleep_fn || ->(seconds) { sleep(seconds) }
      @quiet_streak = 0
      @in_flight = false
      @stop = false
    end

    attr_writer :in_flight

    def stop!
      @stop = true
    end

    def run(max_ticks: nil)
      ticks = 0
      loop do
        break if @stop
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

          @sleep_fn.call(300)
          next
        end

        break if max_ticks && ticks >= max_ticks

        @sleep_fn.call(interval_seconds)
      end
    end

    def interval_seconds
      return 120 if @in_flight
      return 180 if @quiet_streak < 2
      return 3600 if @quiet_streak >= 4

      600
    end

    private

    def emit_wake(urgency)
      payload = { "prompt" => "/ops-github tick", "urgency" => urgency }
      @stdout.write("#{SENTINEL} #{JSON.generate(payload)}\n")
      @stdout.flush if @stdout.respond_to?(:flush)
    end
  end
end
