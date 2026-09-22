# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Services::Search do
  let(:client) { instance_double(ExternalContent::Providers::Tmdb::Client) }
  let(:image_url) { ExternalContent::Providers::Tmdb::Mappers::ImageUrl.new }
  let(:title) { ExternalContent::Providers::Tmdb::Mappers::Title.new(image_url:) }
  let(:title_collection) { ExternalContent::Providers::Tmdb::Mappers::TitleCollection.new(title:) }
  let(:service) do
    described_class.new(
      client:,
      title_collection:,
      person_summary: ExternalContent::Providers::Tmdb::Mappers::PersonSummary.new(title_collection:, image_url:),
      pagination: ExternalContent::Providers::Tmdb::Services::Pagination.new
    )
  end

  it "returns only Korean titles and people known for Korean works" do
    allow(client).to receive(:call).and_return(
      "page" => 1,
      "total_pages" => 1,
      "total_results" => 5,
      "results" => [
        {
          "id" => 1, "media_type" => "tv", "name" => "Корейская дорама",
          "origin_country" => ["KR"], "original_language" => "ko"
        },
        {
          "id" => 2, "media_type" => "movie", "title" => "Корейский фильм",
          "origin_country" => [], "original_language" => "ko"
        },
        {
          "id" => 3, "media_type" => "movie", "title" => "Американский фильм",
          "origin_country" => ["US"], "original_language" => "en"
        },
        {
          "id" => 4, "media_type" => "person", "name" => "Корейский актёр",
          "known_for" => [
            { "id" => 11, "media_type" => "tv", "name" => "Дорама", "origin_country" => ["KR"] },
            { "id" => 12, "media_type" => "movie", "title" => "Foreign", "origin_country" => ["US"] }
          ]
        },
        {
          "id" => 5, "media_type" => "person", "name" => "Другой актёр",
          "known_for" => [
            { "id" => 13, "media_type" => "movie", "title" => "Foreign", "origin_country" => ["US"] }
          ]
        }
      ]
    )

    result = service.call(query: "film", page: 1, language: "ru-RU", include_adult: false)

    expect(result[:titles].pluck(:id)).to eq([1, 2])
    expect(result[:people].pluck(:id)).to eq([4])
    expect(result.dig(:people, 0, :known_for).pluck(:id)).to eq([11])
  end
end
