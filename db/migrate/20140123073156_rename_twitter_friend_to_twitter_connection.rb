class RenameTwitterFriendToTwitterConnection < ActiveRecord::Migration
  def up
    rename_table :twitter_friends, :twitter_connections
  end

  def down
    rename_table :twitter_connections, :twitter_friends
  end
end
