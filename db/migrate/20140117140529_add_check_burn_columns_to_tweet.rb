class AddCheckBurnColumnsToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :checked, :boolean, default: false
  end
end
