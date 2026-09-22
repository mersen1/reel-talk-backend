# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      class CompositionRoot
        def initialize(client: nil)
          @client = client || Client.new(connection: Connection.new.call)
        end

        def call
          Adapter.new(operations: build_operations)
        end

        private

        def build_mappers
          image_url = Mappers::ImageUrl.new
          title = Mappers::Title.new(image_url:)
          title_collection = Mappers::TitleCollection.new(title:)
          trailer = Mappers::Trailer.new
          watch_providers = Mappers::WatchProviders.new(image_url:)
          title_details = Mappers::TitleDetails.new(
            title:, title_collection:, image_url:, trailer:, watch_providers:
          )
          person = Mappers::Person.new(title_collection:, image_url:)
          person_summary = Mappers::PersonSummary.new(title_collection:, image_url:)
          provider_collection = Services::ProviderCollection.new(image_url:)
          catalog_response = Services::CatalogResponse.new(title_mapper: title)
          {
            image_url:, title:, title_collection:, title_details:, person:, person_summary:,
            provider_collection:, catalog_response:
          }
        end

        def build_operations
          mappers = build_mappers
          {
            home: Services::Home.new(client: @client, title_collection: mappers[:title_collection]),
            titles: Services::Catalog.new(
              client: @client,
              query: Services::DiscoverQuery.new,
              response: mappers[:catalog_response]
            ),
            search: Services::Search.new(
              client: @client,
              title_collection: mappers[:title_collection],
              person_summary: mappers[:person_summary],
              pagination: Services::Pagination.new
            ),
            title: Services::TitleDetails.new(client: @client, mapper: mappers[:title_details]),
            person: Services::PersonDetails.new(client: @client, mapper: mappers[:person]),
            configuration: Services::Configuration.new(
              client: @client,
              provider_collection: mappers[:provider_collection]
            )
          }
        end
      end
    end
  end
end
