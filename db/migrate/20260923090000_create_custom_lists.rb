# frozen_string_literal: true

class CreateCustomLists < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_lists do |t|
      t.string :device_id, null: false
      t.string :name, null: false
      t.string :share_token, null: false
      t.timestamps
    end
    add_index :custom_lists, :share_token, unique: true
    add_index :custom_lists, :device_id

    create_table :custom_list_items do |t|
      t.references :custom_list, null: false, foreign_key: true
      t.string :media_type, null: false
      t.bigint :title_id, null: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :custom_list_items, [:custom_list_id, :media_type, :title_id], unique: true, name: "index_custom_list_items_on_list_and_title"
  end
end
