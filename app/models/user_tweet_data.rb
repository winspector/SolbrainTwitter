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

  def self.update_retry_control(my_uid, api_result, retry_control)
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

  # screan_nameの起点ユーザのツイートを取得する
  GET_COUNT = 200
  def self.exec_get_acquire_user_tweets(target_user, screan_name)
    puts "search_key:#{screan_name}"
    # clientオブジェクトを作成する
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.configuration.twitter_consumer_key
      config.consumer_secret = Rails.configuration.twitter_secret_key
      config.access_token = target_user.access_token
      config.access_token_secret = target_user.secret_token
    end

    # clientからuser_timelineメソッドを使い、screan_nameのユーザのツイートを取得する
    tweets = client.user_timeline(screan_name, :count => GET_COUNT)
    puts tweets.count
    # TODO timeoutして例外が発生することがある

    # ツイートデータを、tweet_dataテーブルに追加または更新する
    create_or_update_tweet_data(target_user, tweets)

  end

  # tweetsリストを、tweet_dataテーブルに追加または更新する
  def self.create_or_update_tweet_data(target_user, tweets)
    tweets.each do |twitter_tweet|
      # tweet_dataを作成
      tweet_data = {
          :favorite_count => twitter_tweet.favorite_count,
          :has_picture => nil,
          :my_uid => target_user.uid,
          :parent_tweet_id => twitter_tweet.in_reply_to_tweet_id,
          :rt_count => twitter_tweet.retweet_count,
          :tweet_account_uid => twitter_tweet.user.id,
          :tweet_at => twitter_tweet.created_at,
          :tweet_id => twitter_tweet.id,
          :tweet_text => twitter_tweet.text,
          :tweet_type => nil
      }

      puts "tweet_data[:my_uid]:#{tweet_data[:my_uid]}"
      puts "tweet_data[:tweet_id]:#{tweet_data[:tweet_id]}"
      if TweetData.exists?(:my_uid => tweet_data[:my_uid], :tweet_id => tweet_data[:tweet_id])
        # ツイートが既にtweet_dataテーブルにある場合、更新をする
        update_tweet_data = TweetData.find_by_my_uid_and_tweet_id(tweet_data[:my_uid], tweet_data[:tweet_id])
        puts "arimasu #{update_tweet_data}"
        update_tweet_data.update_attributes(tweet_data)

      else
        # ツイートがtweet_dataテーブルにない場合、追加する
        puts "arimasen"
        TweetData.create(tweet_data)

      end
    end
  end
end
