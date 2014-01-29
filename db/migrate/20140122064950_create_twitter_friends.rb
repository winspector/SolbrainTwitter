class CreateTwitterFriends < ActiveRecord::Migration
  def change
    create_table :twitter_friends do |t|
      t.string :my_uid
      t.string :friend_uid
      t.string :screen_name
      t.string :name
      t.string :location
      t.string :description
      t.string :profile_image_url
      t.boolean :is_follower
      t.boolean :is_friend
      t.integer :followers_count
      t.integer :friends_count

      t.timestamps
    end
  end
end
