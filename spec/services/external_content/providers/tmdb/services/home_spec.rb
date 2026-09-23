# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Services::Home do
  let(:client) { instance_double(ExternalContent::Providers::Tmdb::Client) }
  let(:mapper) { ExternalContent::Providers::Tmdb::Mappers::Title.new(image_url: ExternalContent::Providers::Tmdb::Mappers::ImageUrl.new) }
  let(:collection) { ExternalContent::Providers::Tmdb::Mappers::TitleCollection.new(title: mapper) }

  it "features a well rated Korean series and removes foreign trending titles" do
    popular = [
      { "id" => 1, "name" => "Weak", "origin_country" => ["KR"], "vote_average" => 6.6, "vote_count" => 500 },
      { "id" => 2, "name" => "Strong", "origin_country" => ["KR"], "vote_average" => 8.7, "vote_count" => 300 }
    ]
    trend = [
      { "id" => 3, "name" => "Foreign", "origin_country" => ["US"] },
      { "id" => 4, "name" => "Korean", "origin_country" => ["KR"] }
    ]
    allow(client).to receive(:call) do |path, _params|
      { "results" => path == "trending/tv/week" ? trend : popular }
    end

    result = described_class.new(client:, title_collection: collection).call(language: "ru-RU", region: "RU", page: 1)

    expect(result.dig(:featured, :id)).to eq(2)
    expect(result[:trending].pluck(:id)).to eq([4])
    expect(client).to have_received(:call).with("discover/tv", hash_including(with_origin_country: "KR")).at_least(:once)
  end
end
