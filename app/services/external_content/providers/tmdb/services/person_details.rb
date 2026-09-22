# frozen_string_literal: true

module ExternalContent
  module Providers
    module Tmdb
      module Services
        class PersonDetails
          def initialize(client:, mapper:)
            @client = client
            @mapper = mapper
          end

          def call(id:, language:)
            response = @client.call("person/#{id}", language:, append_to_response: "combined_credits")
            @mapper.call(response)
          end
        end
      end
    end
  end
end
