# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Services::Catalog do
  let(:client) { instance_double(ExternalContent::Providers::Tmdb::Client) }
  let(:image_url) { ExternalContent::Providers::Tmdb::Mappers::ImageUrl.new }
  let(:title_mapper) { ExternalContent::Providers::Tmdb::Mappers::Title.new(image_url:) }
  let(:service) do
    described_class.new(
      client:,
      query: ExternalContent::Providers::Tmdb::Services::DiscoverQuery.new,
      response: ExternalContent::Providers::Tmdb::Services::CatalogResponse.new(title_mapper:)
    )
  end

  it "builds a discover query and returns normalized titles" do
    allow(client).to receive(:call).with("discover/tv", hash_including(
      with_origin_country: "KR",
      with_genres: 18,
      with_status: 0,
      "first_air_date.gte": "2015-01-01",
      watch_region: "RU"
    )).and_return(
      "page" => 1,
      "total_pages" => 2,
      "total_results" => 21,
      "results" => [{
        "id" => 209867,
        "name" => "Хватай Сон Джэ и беги",
        "original_name" => "선재 업고 튀어",
        "first_air_date" => "2024-04-08",
        "vote_average" => 8.6,
        "vote_count" => 312,
        "genre_ids" => [18],
        "origin_country" => ["KR"],
        "poster_path" => "/poster.jpg"
      }]
    )

    result = service.call(
      media_type: "tv", page: 1, language: "ru-RU", region: "RU",
      origin_country: "KR", genre_id: 18, year_from: 2015, year_to: 2026,
      status: "returning", min_rating: 7.0, sort: "rating",
      provider_id: 8, monetization_type: "flatrate"
    )

    expect(result.dig(:titles, 0, :poster_url)).to eq("https://image.tmdb.org/t/p/w500/poster.jpg")
    expect(result[:pagination]).to eq(page: 1, total_pages: 2, total_results: 21)
  end
end
