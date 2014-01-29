class CreateAcquireOrigins < ActiveRecord::Migration
  def change
    create_table :acquire_origins do |t|
      t.string :account_uid
      t.string :screen_name
      t.string :name
      t.string :location
      t.string :description

      t.timestamps
    end
  end
end
