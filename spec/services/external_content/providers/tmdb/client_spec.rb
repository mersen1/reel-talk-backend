# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Client do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:client) { described_class.new(connection:) }

  it "returns a decoded successful response" do
    allow(connection).to receive(:get).and_return(instance_double(Faraday::Response, status: 200, body: { "id" => 1 }))

    expect(client.call("movie/1", language: "ru-RU")).to eq("id" => 1)
    expect(connection).to have_received(:get).with("movie/1", language: "ru-RU")
  end

  it "maps a missing TMDB object to the provider not-found error" do
    allow(connection).to receive(:get).and_return(instance_double(Faraday::Response, status: 404))

    expect { client.call("movie/0") }.to raise_error(ExternalContent::NotFound)
  end

  it "maps transport errors to service unavailable" do
    allow(connection).to receive(:get).and_raise(Faraday::TimeoutError)

    expect { client.call("movie/1") }.to raise_error(ExternalContent::Unavailable) do |error|
      expect(error.status).to eq(:service_unavailable)
    end
  end
end
