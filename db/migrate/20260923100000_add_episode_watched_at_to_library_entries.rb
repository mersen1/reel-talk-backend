# frozen_string_literal: true

class AddEpisodeWatchedAtToLibraryEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :library_entries, :episode_watched_at, :jsonb, default: {}, null: false
  end
end
