class AddEpisodeDiscussionsAndRatings < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :season_number, :integer
    add_column :comments, :episode_number, :integer
    add_index :comments, [:media_type, :title_id, :season_number, :episode_number, :created_at], name: "index_comments_on_episode_and_created_at"
    add_column :library_entries, :episode_ratings, :jsonb, default: {}, null: false
  end
end
