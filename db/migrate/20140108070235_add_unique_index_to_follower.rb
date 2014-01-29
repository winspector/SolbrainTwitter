class AddUniqueIndexToFollower < ActiveRecord::Migration
  def change
    add_index :followers, :my_uid
    add_index :followers, [:my_uid, :follow_uid], unique: true
  end
end
