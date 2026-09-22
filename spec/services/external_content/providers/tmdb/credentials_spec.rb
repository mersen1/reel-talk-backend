# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Credentials do
  it "prefers environment variables" do
    service = described_class.new(
      environment: { "TMDB_ACCESS_TOKEN" => "env-token", "TMDB_API_KEY" => "env-key" },
      credentials: { tmdb: { access_token: "credential-token", api_key: "credential-key" } }
    )

    expect(service.call).to eq(access_token: "env-token", api_key: "env-key")
  end

  it "falls back to Rails credentials" do
    service = described_class.new(
      environment: {},
      credentials: { tmdb: { access_token: "credential-token", api_key: "credential-key" } }
    )

    expect(service.call).to eq(access_token: "credential-token", api_key: "credential-key")
  end
end
