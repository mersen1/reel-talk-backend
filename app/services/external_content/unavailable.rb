# frozen_string_literal: true

module ExternalContent
  class Unavailable < Error
    attr_reader :status

    def initialize(message = "Content provider is temporarily unavailable", status: :bad_gateway)
      super(message, code: "provider_unavailable")
      @status = status
    end
  end
end
