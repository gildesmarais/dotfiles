# frozen_string_literal: true

module Skill
  class ExitError < StandardError
    attr_reader :status

    def initialize(message = nil, status: 1)
      super(message.nil? ? "" : message)
      @status = status
    end
  end
end
