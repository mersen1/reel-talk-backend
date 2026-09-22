# frozen_string_literal: true

module ExternalContent
  class ProviderRegistry
    class << self
      attr_writer :provider

      def register(name, &factory)
        providers[name.to_s] = factory
      end

      def provider
        @provider ||= build_provider
      end

      def reset!
        @provider = nil
      end

      private

      def build_provider
        name = ENV.fetch("CONTENT_PROVIDER", "tmdb")
        factory = providers[name]
        raise ConfigurationError, "Unknown content provider" unless factory

        factory.call
      end

      def providers
        @providers ||= { "tmdb" => -> { Providers::Tmdb::CompositionRoot.new.call } }
      end
    end
  end
end
