class CreateTwitterAcquireControls < ActiveRecord::Migration
  def change
    create_table :twitter_acquire_controls do |t|
      t.string :my_uid
      t.string :acquire_type
      t.integer :max_id
      t.integer :cursor

      t.timestamps
    end
  end
end
