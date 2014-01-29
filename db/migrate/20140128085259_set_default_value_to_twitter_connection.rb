class SetDefaultValueToTwitterConnection < ActiveRecord::Migration
  def up
    change_column :twitter_connections,:is_follower, :boolean, :default => false
    change_column :twitter_connections,:is_friend, :boolean, :default => false
  end

  def down
    change_column :twitter_connections,:is_follower, :boolean
    change_column :twitter_connections,:is_friend, :boolean
  end
end
