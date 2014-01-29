class CreateTwitterProfiles < ActiveRecord::Migration
  def change
    create_table :twitter_profiles do |t|
      t.string :my_uid
      t.string :name
      t.string :description
      t.string :location
      t.string :profile_image_url

      t.timestamps
    end
  end
end
