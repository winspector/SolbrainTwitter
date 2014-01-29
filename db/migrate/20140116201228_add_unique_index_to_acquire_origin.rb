class AddUniqueIndexToAcquireOrigin < ActiveRecord::Migration
  def change
    add_index :acquire_origins, :account_uid, unique: true
  end
end
