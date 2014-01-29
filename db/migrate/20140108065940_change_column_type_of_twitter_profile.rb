class ChangeColumnTypeOfTwitterProfile < ActiveRecord::Migration
  def up
    change_column :twitter_profiles, :description, :text
  end

  def down
    change_column :twitter_profiles, :description, :string
  end
end
