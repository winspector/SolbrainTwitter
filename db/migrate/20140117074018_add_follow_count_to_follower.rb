class AddFollowCountToFollower < ActiveRecord::Migration
  def change
    add_column :followers, :follower_count, :integer
    add_column :followers, :friend_count, :integer
  end
end
