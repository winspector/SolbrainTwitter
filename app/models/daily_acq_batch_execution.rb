# -*- coding:utf-8 -*-
class DailyAcqBatchExecution < BatchExecution
  # 日時収集を実行するクラス

  def acquire_tweet
    acquire_common do |target_user|
      result_recently = RecentlyUserTweetData.acquire_user_tweets(target_user)

      if result_recently[:is_api_rate_limit] || result_recently[:exist_error]
        next
      end

      # TODO リトライ対応
      retry_controls = TwitterAcquireControl.find_all_by_my_uid_and_acquire_type(target_user.uid, 'all_tweet')
      retry_controls.each do |retry_control|
        result_retry = nil
        if result_retry[:is_api_rate_limit] || result_recently[:exist_error]
          break
        end
      end
    end
  end

  def acquire_mention
    acquire_common do |target_user|
      # TODO 実装
    end
  end

  def acquire_recently_connection
    acquire_common do |target_user|
      RecentlyTwitterFollower.acquire_recently_followers(target_user)
      RecentlyTwitterFriend.acquire_recently_friends(target_user)
    end
  end

  def update_connection
    acquire_common do |target_user|
      UpdateTwitterConnection.update_connection(target_user)
    end
  end

  def acquire_message
    acquire_common do |target_user|
      result_recently = RecentlyUserTweetData.acquire_user_tweets(target_user)
      result_recently_send = RecentlySendDirectMessage.acquire_recently_send_message(target_user)
      result_recently_receive = RecentlyReceiveDirectMessage.acquire_recently_receive_message(target_user)

      if result_recently_send[:is_api_rate_limit] || result_recently_send[:exist_error] ||
          result_recently_receive[:is_api_rate_limit] || result_recently_receive[:exist_error]
        next
      end

      retry_send_controls = TwitterAcquireControl.find_all_by_my_uid_and_acquire_type(target_user.uid, 'all_send_message')
      retry_send_controls.each do |retry_control|
        result_retry = SendDirectMessage.acquire_all_send_message(target_user,retry_control)
        if result_retry[:is_api_rate_limit] || result_recently[:exist_error]
          break
        end
      end

      retry_receive_controls = TwitterAcquireControl.find_all_by_my_uid_and_acquire_type(target_user.uid, 'all_receive_message')
      retry_receive_controls.each do |retry_control|
        result_retry = ReceiveDirectMessage.acquire_all_receive_message(target_user,retry_control)
        if result_retry[:is_api_rate_limit] || result_recently[:exist_error]
          break
        end
      end
    end
  end

  def acquire_common
    thread_max = 10

    # TODO ターゲットユーザの抽出
    # 将来的にはここは全員じゃなくて選ばれた100人（優先度が高いとか前回の取得から時間が経ってるとか）とかになるかもしれない
    target_users = nil

    target_user_que = Queue.new
    target_users.each do |target_user|
      target_user_que.push(target_user)
    end
    target_user_que.push(nil)

    Array.new(thread_max) do |i|
      # TODO コネクションを排他にする（10本増えるだけならどうということもあるまい）
      Thread.new do
        begin
          while target_user = target_user_que.pop(true)
            yield(target_user)
          end
          # 次に抜けるスレッド用にnilをpushしておく（こうしないと空キューからpopする行為が発生してしまう）
          q.push(nil)
        end
      end
    end.each(&:join)
  end

  def acquire_all_single_thread(target_user)
    puts "開始時刻 #{Time.now}"
    puts_result_logs(TwitterProfile.acquire_profile(target_user))
    puts_result_logs(TwitterFollower.acquire_followers(target_user))
    puts_result_logs(TwitterFriend.acquire_friends(target_user))
    puts_result_logs(UserTweetData.acquire_user_tweets(target_user))
    puts_result_logs(MentionedTweetData.acquire_mentioned_tweets(target_user))
    puts "終了時刻 #{Time.now}"
  end

  def acquire_all_multi_thread_test
    # マルチスレッドで一気にデータ取得

    m = Mutex.new
    t1 = Thread.start {
      10.times do
        logger.info 'あああ'
        #m.synchronize{
        #  puts 'スレッド1'
        #}
        sleep(0.5)
      end
    }

    t2 = Thread.start {
      15.times do
        logger.info 'いいい'
        #m.synchronize{
        #  puts 'スレッド2'
        #}
        sleep(0.5)
      end
    }

    t2 = Thread.start {
      8.times do
        logger.info 'ううう'
        #m.synchronize{
        #  puts 'スレッド2'
        #}
        sleep(0.8)
      end
    }

    puts 'スレッド1の実行待ち'
    t1.join
    puts 'スレッド2の実行待ち'
    t2.join
    puts 'スレッド3の実行待ち'
    t3.join

    puts 'スレッドが両方とも完了'
  end
end
