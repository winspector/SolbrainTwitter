class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.string :my_uid
      t.string :follow_uid
      t.string :screen_name
      t.string :name
      t.string :location
      t.string :profile_image_url
      t.text :description
      t.boolean :is_follow
      t.boolean :is_followed

      t.timestamps
    end
  end
end
