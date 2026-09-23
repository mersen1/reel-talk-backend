# frozen_string_literal: true

class CreateRecentViews < ActiveRecord::Migration[8.1]
  def change
    create_table :recent_views do |t|
      t.string :device_id, null: false
      t.string :media_type, null: false
      t.bigint :title_id, null: false
      t.datetime :viewed_at, null: false
    end
    add_index :recent_views, [:device_id, :media_type, :title_id], unique: true
    add_index :recent_views, [:device_id, :viewed_at]
  end
end
