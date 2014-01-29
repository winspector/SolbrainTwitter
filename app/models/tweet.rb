class Tweet < ActiveRecord::Base
  attr_accessible :favorited_count, :my_uid, :retweet_count, :text, :tweet_id, :checked, :may_burn

  def self.create_or_update_for_tweets(tweets, my_uid)
    tweets.each do |tweet|
      if !Tweet.exists?({my_uid: my_uid, tweet_id: tweet.id})
        tweet_data = {tweet_id: tweet.id, my_uid: my_uid, text: tweet.text, retweet_count: tweet.retweet_count, favorited_count: tweet.favorite_count}
        Tweet.create(tweet_data)
      end
    end
  end

  def self.max_id_of_user(my_uid)
    Tweet.maximum('tweet_id', conditions:{my_uid:my_uid})
  end


end
