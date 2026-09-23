# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Services::TitleDetails do
  let(:client) { instance_double(ExternalContent::Providers::Tmdb::Client) }
  let(:image_url) { ExternalContent::Providers::Tmdb::Mappers::ImageUrl.new }
  let(:title) { ExternalContent::Providers::Tmdb::Mappers::Title.new(image_url:) }
  let(:title_collection) { ExternalContent::Providers::Tmdb::Mappers::TitleCollection.new(title:) }
  let(:mapper) do
    ExternalContent::Providers::Tmdb::Mappers::TitleDetails.new(
      title:,
      title_collection:,
      image_url:,
      trailer: ExternalContent::Providers::Tmdb::Mappers::Trailer.new,
      watch_providers: ExternalContent::Providers::Tmdb::Mappers::WatchProviders.new(image_url:)
    )
  end
  let(:service) { described_class.new(client:, mapper:) }

  it "loads and maps the full screen in one TMDB request" do
    allow(client).to receive(:call).and_return(
      "id" => 209867,
      "name" => "Название",
      "origin_country" => ["KR"],
      "original_name" => "원제",
      "first_air_date" => "2024-04-08",
      "seasons" => [{ "season_number" => 0 }, { "season_number" => 1 }, { "season_number" => 2 }],
      "genres" => [],
      "credits" => { "cast" => [] },
      "videos" => { "results" => [{
        "site" => "YouTube", "type" => "Trailer", "official" => true,
        "key" => "abc", "name" => "Trailer"
      }] },
      "similar" => { "results" => [] },
      "recommendations" => { "results" => [] },
      "watch/providers" => { "results" => { "RU" => { "link" => "https://example.test/watch" } } }
    )

    result = service.call(media_type: "tv", id: 209867, language: "ru-RU", region: "RU")

    expect(client).to have_received(:call).once.with(
      "tv/209867", language: "ru-RU", append_to_response: described_class::APPEND
    )
    expect(result.dig(:trailer, :url)).to eq("https://www.youtube.com/watch?v=abc")
    expect(result[:watch_providers_url]).to eq("https://example.test/watch")
    expect(result[:season_numbers]).to eq([1, 2])
  end

  it "shows only Korean series in related titles" do
    result = mapper.call({
      "id" => 10, "name" => "Main", "origin_country" => ["KR"],
      "similar" => { "results" => [
        { "id" => 11, "name" => "Korean", "origin_country" => ["KR"] },
        { "id" => 12, "name" => "Foreign", "origin_country" => ["US"] }
      ] },
      "recommendations" => { "results" => [] }
    }, media_type: "tv", region: "RU")

    expect(result[:similar].pluck(:id)).to eq([11])
  end

  it "rejects non-Korean and reality titles" do
    allow(client).to receive(:call).and_return("id" => 5, "name" => "Variety", "origin_country" => ["KR"], "genre_ids" => [10764])

    expect { service.call(media_type: "tv", id: 5, language: "ru-RU", region: "RU") }
      .to raise_error(ExternalContent::NotFound)
  end
end
