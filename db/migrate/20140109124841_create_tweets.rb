class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :my_uid
      t.string :tweet_id
      t.string :text
      t.integer :retweet_count
      t.integer :favorited_count

      t.timestamps
    end
  end
end
