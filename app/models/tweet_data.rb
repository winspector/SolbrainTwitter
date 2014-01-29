class TweetData < ActiveRecord::Base
  require 'twitter_data_acquire_module'
  extend TwitterDataAcquireModule
  attr_accessible :favorite_count, :has_picture, :my_uid, :parent_tweet_id, :rt_count, :tweet_account_uid, :tweet_at, :tweet_id, :tweet_text, :tweet_type


  # ---------- テンプレートメソッドの実装 ----------
  def self.create_or_update_single_page(my_uid, single_record_data)
    single_record_data.each do |tweet|
      if TweetData.exists?(my_uid: my_uid, tweet_id: tweet.id)
        local_tweet = TweetData.find_by_my_uid_and_tweet_id(my_uid, tweet.id)
        local_tweet.update_attributes(update_hash_from_single_record(tweet))
      else
        TweetData.create(create_hash_from_single_record(my_uid, tweet))
      end
    end
  end

  def self.is_loop_continue(api_result, persist_result)
    true
  end

  # ---------- データ加工 ----------
  def self.create_hash_from_single_record(my_uid, tweet)
    result = {:favorite_count => tweet.favorite_count,
              :has_picture => false,
              :my_uid => my_uid,
              :parent_tweet_id => tweet.in_reply_to_status_id,
              :rt_count => tweet.retweet_count,
              :tweet_account_uid => tweet.user.id,
              :tweet_at => tweet.created_at,
              :tweet_id => tweet.id,
              :tweet_text => tweet.text,
              :tweet_type => 'user_tweet'
    }
    result
  end

  # ツイートで更新するのってRT数とお気に入り数くらい（Tweetは原則修正できないから）
  def self.update_hash_from_single_record(tweet)
    hash = create_hash_from_single_record(nil, tweet)
    hash.delete(:tweet_id)
    hash.delete(:my_uid)
    hash.delete(:tweet_account_uid)
    hash.delete(:tweet_at)
    hash.delete(:tweet_text)
    hash.delete(:tweet_type)
    hash.delete(:parent_tweet_id)
    hash.delete(:has_picture)
  end

  # ---------- ビュー系 ----------
  def self.max_tweet_id_by_user(my_uid)
    TweetData.maximum(:tweet_id, conditions: {my_uid: my_uid, tweet_account_uid: my_uid})
  end

  def self.max_mentioned_tweet_id_by_user(my_uid)
    TweetData.maximum(:tweet_id, conditions: {my_uid: my_uid, tweet_type: 'mentioned'})
  end
end
