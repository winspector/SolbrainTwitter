class TweetMetaInfo < ActiveRecord::Base
  attr_accessible :account_uid, :meta_info_type, :tweet_data_id
end
