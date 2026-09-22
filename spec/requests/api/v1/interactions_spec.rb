require "rails_helper"

RSpec.describe "Guest interactions" do
  before { host! "localhost" }
  let(:alice) { "11111111-1111-4111-8111-111111111111" }
  let(:bob) { "22222222-2222-4222-8222-222222222222" }

  def headers(id)
    { "X-Device-Id" => id }
  end

  it "creates a stable temporary guest and keeps libraries separate" do
    get "/api/v1/guest", headers: headers(alice)
    expect(response).to have_http_status(:ok), response.body
    guest_id = response.parsed_body.fetch("id")
    get "/api/v1/guest", headers: headers(alice)
    expect(response.parsed_body.fetch("id")).to eq(guest_id)

    put "/api/v1/library/tv/123", headers: headers(alice), params: {
      status: "WATCHING", favorite: true, user_rating: 8, personal_note: "Good"
    }, as: :json
    expect(response).to have_http_status(:ok), response.body
    get "/api/v1/library", headers: headers(alice)
    expect(response.parsed_body.fetch("entries").first).to include("favorite" => true, "user_rating" => 8)
    get "/api/v1/library", headers: headers(bob)
    expect(response.parsed_body.fetch("entries")).to be_empty

    delete "/api/v1/library/tv/123", headers: headers(alice)
    expect(response).to have_http_status(:no_content)
    get "/api/v1/library", headers: headers(alice)
    expect(response.parsed_body.fetch("entries")).to be_empty
  end

  it "stores comments, nested replies and one like per guest" do
    post "/api/v1/titles/tv/123/comments", headers: headers(alice), params: { text: "Hello" }, as: :json
    expect(response).to have_http_status(:created), response.body
    root_id = response.parsed_body.fetch("id")
    post "/api/v1/titles/tv/123/comments", headers: headers(bob), params: { text: "Reply", parent_id: root_id }, as: :json
    expect(response).to have_http_status(:created)

    2.times do
      put "/api/v1/comments/#{root_id}/like", headers: headers(bob), params: { liked: true }, as: :json
      expect(response).to have_http_status(:ok)
    end
    expect(response.parsed_body.fetch("likes")).to eq(1)
    get "/api/v1/titles/tv/123/comments", headers: headers(bob)
    root = response.parsed_body.fetch("comments").first
    expect(root).to include("text" => "Hello", "is_liked" => true)
    expect(root.fetch("replies").first.fetch("text")).to eq("Reply")

    put "/api/v1/comments/#{root_id}/like", headers: headers(bob), params: { liked: false }, as: :json
    expect(response.parsed_body.fetch("likes")).to eq(0)
  end

  it "rejects replies to comments on another title" do
    post "/api/v1/titles/tv/123/comments", headers: headers(alice), params: { text: "Hello" }, as: :json
    root_id = response.parsed_body.fetch("id")
    post "/api/v1/titles/movie/456/comments", headers: headers(bob), params: { text: "Wrong", parent_id: root_id }, as: :json
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "remembers recent titles per guest" do
    put "/api/v1/recent_views/tv/123", headers: headers(alice), params: {}, as: :json
    expect(response).to have_http_status(:ok)
    put "/api/v1/recent_views/movie/456", headers: headers(alice), params: {}, as: :json
    get "/api/v1/recent_views", headers: headers(alice)
    expect(response.parsed_body.fetch("title_ids")).to eq(["movie:456", "tv:123"])
    get "/api/v1/recent_views", headers: headers(bob)
    expect(response.parsed_body.fetch("title_ids")).to be_empty
  end
end
