class CreateShortenedUrl < ActiveRecord::Migration
  def change
    create_table :shortened_urls do |t|
      t.string :long_url
      t.string :short_url, unique: true
      t.integer :user_id

      t.timestamps
    end
    add_index :shortened_urls, :user_id
    add_index :shortened_urls, :short_url
  end
end
