# frozen_string_literal: true

module OpsGithub
  class ExitError < StandardError
    attr_reader :status

    def initialize(message = nil, status: 1)
      super(message.nil? ? "" : message)
      @status = status
    end
  end
end
