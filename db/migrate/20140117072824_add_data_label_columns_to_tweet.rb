class AddDataLabelColumnsToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :may_burn,:boolean
  end
end
