class CreateUserInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :guest_users do |t|
      t.string :device_id, null: false
      t.string :display_name, null: false, default: "Гость"
      t.timestamps
    end
    add_index :guest_users, :device_id, unique: true

    create_table :library_entries do |t|
      t.string :device_id, null: false
      t.string :media_type, null: false
      t.bigint :title_id, null: false
      t.string :status
      t.integer :user_rating
      t.boolean :favorite, null: false, default: false
      t.text :personal_note, null: false, default: ""
      t.timestamps
    end
    add_index :library_entries, [:device_id, :media_type, :title_id], unique: true, name: "index_library_entries_on_owner_and_title"

    create_table :comments do |t|
      t.string :device_id, null: false
      t.string :user_name, null: false
      t.string :media_type, null: false
      t.bigint :title_id, null: false
      t.references :parent, foreign_key: { to_table: :comments }
      t.text :body, null: false
      t.timestamps
    end
    add_index :comments, [:media_type, :title_id, :created_at]

    create_table :comment_likes do |t|
      t.references :comment, null: false, foreign_key: true
      t.string :device_id, null: false
      t.timestamps
    end
    add_index :comment_likes, [:comment_id, :device_id], unique: true
  end
end
