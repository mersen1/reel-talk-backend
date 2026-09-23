# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Custom lists" do
  before { host! "localhost" }
  let(:alice) { { "X-Device-Id" => "11111111-1111-4111-8111-111111111111" } }
  let(:bob) { { "X-Device-Id" => "22222222-2222-4222-8222-222222222222" } }

  it "lets a guest create, edit and share a list without exposing other lists" do
    post "/api/v1/custom_lists", headers: alice, params: { name: "Weekend" }, as: :json
    expect(response).to have_http_status(:created), response.body
    id = response.parsed_body.fetch("id")
    token = response.parsed_body.fetch("share_token")

    post "/api/v1/custom_lists/#{id}/items/tv/123", headers: alice
    expect(response).to have_http_status(:created), response.body
    expect(response.parsed_body.fetch("items")).to eq([{ "media_type" => "tv", "title_id" => 123 }])

    get "/api/v1/custom_lists", headers: bob
    expect(response.parsed_body.fetch("lists")).to be_empty
    put "/api/v1/custom_lists/#{id}", headers: bob, params: { name: "Changed" }, as: :json
    expect(response).to have_http_status(:not_found)

    get "/api/v1/shared_lists/#{token}"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("list")).to include("name" => "Weekend")
    expect(response.parsed_body.fetch("list")).not_to have_key("share_token")

    delete "/api/v1/custom_lists/#{id}/items/tv/123", headers: alice
    expect(response).to have_http_status(:no_content)
    get "/lists/#{token}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Weekend", "reeltalk://shared/#{token}")
    delete "/api/v1/custom_lists/#{id}", headers: alice
    expect(response).to have_http_status(:no_content)
    get "/api/v1/shared_lists/#{token}"
    expect(response).to have_http_status(:not_found)
  end
end
