# frozen_string_literal: true

require "forwardable"

module ExternalContent
  class Gateway
    extend Forwardable

    OPERATIONS = %i[home titles search title person configuration].freeze
    def_delegators :@provider, *OPERATIONS

    class << self
      attr_writer :default

      def default
        @default ||= new(provider: ProviderRegistry.provider)
      end

      def reset!
        @default = nil
        ProviderRegistry.reset!
      end
    end

    def initialize(provider:)
      @provider = provider
    end
  end
end
