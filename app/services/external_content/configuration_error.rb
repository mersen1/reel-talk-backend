# frozen_string_literal: true

module ExternalContent
  class ConfigurationError < Error
    def initialize(message)
      super(message, code: "provider_configuration_error")
    end
  end
end
