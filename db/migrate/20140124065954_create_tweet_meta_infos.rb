class CreateTweetMetaInfos < ActiveRecord::Migration
  def change
    create_table :tweet_meta_infos do |t|
      t.integer :tweet_data_id
      t.string :meta_info_type
      t.string :account_uid

      t.timestamps
    end
  end
end
