# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Connection do
  it "configures Bearer authentication and timeouts" do
    connection = described_class.new(access_token: "token", api_key: nil).call

    expect(connection.headers["Authorization"]).to eq("Bearer token")
    expect(connection.options.open_timeout).to eq(5)
    expect(connection.options.timeout).to eq(10)
  end

  it "uses an API key when an access token is absent" do
    connection = described_class.new(access_token: nil, api_key: "key").call

    expect(connection.params).to include("api_key" => "key")
    expect(connection.headers).not_to have_key("Authorization")
  end

  it "fails fast when credentials are absent" do
    expect do
      described_class.new(access_token: nil, api_key: nil).call
    end.to raise_error(ExternalContent::ConfigurationError)
  end
end
