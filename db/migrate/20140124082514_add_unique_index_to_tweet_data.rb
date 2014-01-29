class AddUniqueIndexToTweetData < ActiveRecord::Migration
  def change
    add_index :tweet_data, :my_uid
    add_index :tweet_data, :tweet_account_uid
    add_index :tweet_data, [:my_uid, :tweet_id], unique: true
  end
end
