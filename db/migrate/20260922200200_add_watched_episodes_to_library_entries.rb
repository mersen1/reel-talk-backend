class AddWatchedEpisodesToLibraryEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :library_entries, :watched_episodes, :jsonb, default: [], null: false
  end
end
