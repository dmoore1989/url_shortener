class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :user_id
      t.integer :shortened_url_id
      t.integer :visits, default: 0

      t.timestamp
    end
  end
end
