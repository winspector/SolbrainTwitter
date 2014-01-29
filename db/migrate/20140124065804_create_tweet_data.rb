class CreateTweetData < ActiveRecord::Migration
  def change
    create_table :tweet_data do |t|
      t.string :my_uid
      t.string :tweet_account_uid
      t.string :tweet_id
      t.string :tweet_text
      t.timestamp :tweet_at
      t.integer :rt_count
      t.integer :favorite_count
      t.string :parent_tweet_id
      t.string :tweet_type
      t.boolean :has_picture

      t.timestamps
    end
  end
end
