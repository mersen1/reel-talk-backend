# frozen_string_literal: true

module ExternalContent
  class InvalidParameter < Error
    def initialize(message, parameter:)
      super(message, code: "invalid_parameter", details: { parameter: parameter.to_s })
    end
  end
end
