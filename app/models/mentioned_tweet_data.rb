# -*- coding:utf-8 -*-
class MentionedTweetData < TweetData
  def self.acquire_mentioned_tweets(target_user)
    common_acquire(target_user)
  end

  # 本クラスは最新から取れるところまで取るクラス
  def self.build_option(my_uid, retry_control = nil)
    {count:200}
  end

  def self.call_api_for_model(client, option)
    client.mentions_timeline(option)
  end

  def self.build_option_and_prepare_next_page(my_uid, api_result, retry_control)
    option = build_option(my_uid, retry_control)
    option[:max_id] = api_result.last.id() -1
    option
  end

  def self.update_retry_control(my_uid, api_result,retry_control)
    last_id = api_result.last.id
    TwitterAcquireControl.create_or_update_control_with_max_id(retry_control, my_uid, 'all_mentioned', last_id)
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
