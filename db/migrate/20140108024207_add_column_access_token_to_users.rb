class AddColumnAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string
    add_column :users, :secret_token, :string
  end
end
