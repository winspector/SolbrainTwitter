# -*- coding:utf-8 -*-
class UserTweetData < TweetData
  def self.acquire_user_tweets(target_user)
    common_acquire(target_user)
  end

  # 本クラスは最新から取れるところまで取るクラス
  def self.build_option(my_uid, retry_count=nil)
    {count: 200}
  end

  def self.call_api_for_model(client, option)
    client.user_timeline(option)
  end

  def self.update_retry_control(my_uid, api_result,retry_control)
    last_id = api_result.last.id
    TwitterAcquireControl.create_or_update_control_with_max_id(retry_control, my_uid, 'user_tweet', last_id)
  end

  def self.build_option_and_prepare_next_page(my_uid, api_result, retry_control)
    last_id = api_result.last.id() -1
    next_page_option_add_only_max_id(my_uid, last_id)
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

  def self.finish_persist(result, retry_control)
    if retry_control
      if !result[:is_api_rate_limit] && !result[:exist_exception]
        retry_control.delete
        retry_control.save!
      end
    end
  end
end
