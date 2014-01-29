# -*- coding:utf-8 -*-
class RetryMentionedTweetData < TweetData
  def self.acquire_retry_mentioned_tweets(target_user)
    common_acquire(target_user)
  end

  # 本クラスは中断地点から取れるところまで取るクラス
  def self.build_option(my_uid, retry_control)
    {count:200, max_id:retry_control.max_id}
  end
end
