# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API v1" do
  let(:provider) { instance_double(ExternalContent::Provider) }
  let(:gateway) { ExternalContent::Gateway.new(provider:) }

  before do
    host! "localhost"
    ExternalContent::Gateway.default = gateway
  end

  after do
    ExternalContent::Gateway.reset!
  end

  it "serves home through the injected provider" do
    payload = { featured: {}, trending: [], popular: [], new_releases: [], recommendations: [] }
    allow(provider).to receive(:home).and_return(payload)

    get "/api/v1/home"

    expect(response).to have_http_status(:ok)
    expect(provider).to have_received(:home).with(language: "ru-RU", region: "RU", page: 1)
    expect(response.parsed_body).to eq(payload.deep_stringify_keys)
  end

  it "coerces and forwards catalog filters" do
    allow(provider).to receive(:titles).and_return(titles: [], pagination: {})

    get "/api/v1/titles", params: {
      media_type: "tv", origin_country: "KR", genre_id: "18", min_rating: "7", page: "2"
    }

    expect(response).to have_http_status(:ok)
    expect(provider).to have_received(:titles).with(hash_including(
      media_type: "tv", origin_country: "KR", genre_id: 18, min_rating: 7.0, page: 2
    ))
  end

  it "uses Korea as the default catalog origin" do
    allow(provider).to receive(:titles).and_return(titles: [], pagination: {})

    get "/api/v1/titles"

    expect(provider).to have_received(:titles).with(hash_including(media_type: "tv", origin_country: "KR"))
  end

  it "searches titles and people" do
    payload = { titles: [], people: [], pagination: { page: 1, total_pages: 0, total_results: 0 } }
    allow(provider).to receive(:search).and_return(payload)

    get "/api/v1/search", params: { query: "  Сон Джэ  " }

    expect(response).to have_http_status(:ok)
    expect(provider).to have_received(:search).with(
      query: "Сон Джэ", language: "ru-RU", page: 1, include_adult: false
    )
  end

  it "loads title details" do
    allow(provider).to receive(:title).and_return(id: 209867, media_type: "tv")

    get "/api/v1/titles/tv/209867"

    expect(response).to have_http_status(:ok)
    expect(provider).to have_received(:title).with(
      id: 209867, media_type: "tv", language: "ru-RU", region: "RU"
    )
  end

  it "loads episodes for a season" do
    allow(provider).to receive(:season).and_return(season_number: 1, episodes: [{ number: 1, name: "Pilot" }])
    Comment.create!(device_id: "11111111-1111-4111-8111-111111111111", user_name: "Гость",
      media_type: "tv", title_id: 209867, season_number: 1, episode_number: 1, body: "Great")
    LibraryEntry.create!(device_id: "11111111-1111-4111-8111-111111111111", media_type: "tv", title_id: 209867,
      episode_ratings: { "1:1" => 8, "2:1" => 5 })
    LibraryEntry.create!(device_id: "22222222-2222-4222-8222-222222222222", media_type: "tv", title_id: 209867,
      episode_ratings: { "1:1" => 9 })

    get "/api/v1/titles/tv/209867/seasons/1"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("episodes").first).to include(
      "number" => 1, "name" => "Pilot", "comment_count" => 1, "rating_sum" => 17, "rating_count" => 2
    )
    expect(provider).to have_received(:season).with(id: 209867, season_number: 1, language: "ru-RU")
  end

  it "loads a person" do
    allow(provider).to receive(:person).and_return(id: 1)

    get "/api/v1/people/1"

    expect(response).to have_http_status(:ok)
    expect(provider).to have_received(:person).with(id: 1, language: "ru-RU")
  end

  it "loads filter configuration" do
    allow(provider).to receive(:configuration).and_return(
      genres: { tv: [], movie: [] }, countries: [], watch_providers: [], sort_options: [], media_types: []
    )

    get "/api/v1/configuration"

    expect(response).to have_http_status(:ok)
    expect(provider).to have_received(:configuration).with(language: "ru-RU", region: "RU")
  end

  it "rejects an empty query with the shared error format" do
    get "/api/v1/search", params: { query: "   " }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq(
      "error" => {
        "code" => "invalid_parameter",
        "message" => "query must not be empty",
        "details" => { "parameter" => "query" }
      }
    )
  end

  it "rejects an unsupported detail media type" do
    get "/api/v1/titles/game/1"

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body.dig("error", "message")).to eq("media_type must be tv")
  end

  it "does not expose provider internals on an outage" do
    allow(provider).to receive(:title).and_raise(
      ExternalContent::Unavailable.new(status: :service_unavailable)
    )

    get "/api/v1/titles/tv/1"

    expect(response).to have_http_status(:service_unavailable)
    expect(response.parsed_body.dig("error", "code")).to eq("provider_unavailable")
    expect(response.body).not_to include("TMDB")
  end

  it "maps a missing provider entity to 404" do
    allow(provider).to receive(:person).and_raise(ExternalContent::NotFound)

    get "/api/v1/people/999999"

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq(
      "error" => { "code" => "not_found", "message" => "Resource not found" }
    )
  end
end
