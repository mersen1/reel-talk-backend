# frozen_string_literal: true

module ExternalContent
  class Error < StandardError
    attr_reader :code, :details

    def initialize(message, code:, details: nil)
      super(message)
      @code = code
      @details = details
    end
  end
end
