class AddUniqueIndexToTwitterProfile < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :screen_name, :string
    add_index :twitter_profiles, :my_uid, unique: true
    add_index :twitter_profiles, :screen_name
  end
end
