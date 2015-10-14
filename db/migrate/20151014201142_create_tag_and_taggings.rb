class CreateTagAndTaggings < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :tag
    end
    create_table :taggings do |t|
      t.integer :url_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
