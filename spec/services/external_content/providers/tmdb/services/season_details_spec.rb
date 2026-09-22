# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalContent::Providers::Tmdb::Services::SeasonDetails do
  it "maps the selected season and excludes specials" do
    client = instance_double(ExternalContent::Providers::Tmdb::Client)
    allow(client).to receive(:call).and_return(
      "season_number" => 1,
      "episodes" => [
        { "episode_number" => 1, "name" => "Pilot", "overview" => "Episode synopsis", "air_date" => "2024-04-08", "runtime" => 60 },
        { "episode_number" => 0, "name" => "Special" }
      ]
    )

    result = described_class.new(client:).call(id: 123, season_number: 1, language: "ru-RU")

    expect(client).to have_received(:call).with("tv/123/season/1", language: "ru-RU")
    expect(result[:episodes]).to eq([{ number: 1, name: "Pilot", overview: "Episode synopsis", air_date: "2024-04-08", runtime_minutes: 60 }])
  end
end
