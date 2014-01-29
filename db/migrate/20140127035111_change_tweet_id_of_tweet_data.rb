class ChangeTweetIdOfTweetData < ActiveRecord::Migration
  def up
    change_column :tweet_data, :tweet_id, :integer
  end

  def down
    change_column :tweet_data, :tweet_id, :string
  end
end
