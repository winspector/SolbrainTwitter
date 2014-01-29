class AddIndexOnFriendUidToTwitterConnections < ActiveRecord::Migration
  def change
    add_index :twitter_connections, [:my_uid]
    add_index :twitter_connections, [:my_uid, :friend_uid], unique: true
  end
end
