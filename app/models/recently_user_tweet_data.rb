# -*- coding:utf-8 -*-
class RecentlyUserTweetData < UserTweetData
  def self.acquire_recently_user_tweets(target_user)
    common_acquire(target_user)
  end

  # 本クラスは最新から現在DBに登録してあるものの最新の間を取得
  def self.build_option(my_uid)
    {count:200,since_id:TweetData.max_tweet_id_by_user(my_uid)}
  end

  # since_id指定してるから親クラスのやつ（とれるとこまで取る）と同じで良い
  def self.is_loop_continue(api_result, persist_result)
    super(api_result, persist_result)
  end
end
