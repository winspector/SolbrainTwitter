class AddTweetAtToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :tweet_at, :timestamp
  end
end
