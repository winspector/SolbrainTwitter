# -*- coding:utf-8 -*-
class RecentlyMentionedTweetData < MentionedTweetData
  def self.acquire_recently_mentioned_tweets(target_user)
    common_acquire(target_user)
  end

  # 本クラスは最新から取れるところまで取るクラス
  def self.build_option(my_uid)
    {count:200, since_id:TweetData.max_mentioned_tweet_id_by_user(my_uid)}
  end

  def self.is_loop_continue(api_result, persist_result)
    # このクラスでは取りきったら完了
    if api_result.length != 0
      puts 'api取得結果が0件ではないので処理継続'
      return true
    else
      puts 'api取得結果が0件なので処理終了'
      return false
    end
  end

  def self.create_hash_from_single_record(my_uid, tweet)
    tweet_hash = super(my_uid,tweet)
    puts tweet_hash[:tweet_type]
    tweet_hash[:tweet_type] = 'mentioned'
    tweet_hash
  end
end
