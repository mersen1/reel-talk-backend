# frozen_string_literal: true

module ExternalContent
  class NotFound < Error
    def initialize(message = "Resource not found")
      super(message, code: "not_found")
    end
  end
end
