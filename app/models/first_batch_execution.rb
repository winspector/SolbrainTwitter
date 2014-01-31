# -*- coding:utf-8 -*-
class FirstBatchExecution < BatchExecution
  # 初回バッチを実行するクラス

  def acquire_all(target_user)
    puts "開始時刻 #{Time.now}"
    # マルチスレッドで一気にデータ取得
    # プロフィールデータ収集
    t_profile = Thread.start {
      puts_result_logs(TwitterProfile.acquire_profile(target_user))
    }

    # フォロワー＆フレンド収集
    t_conn = Thread.start {
      # こいつらはおんなじコネクション使わないと破綻（衝突が生じうる）する可能性がある
      puts_result_logs(TwitterFollower.acquire_followers(target_user))
      puts_result_logs(TwitterFriend.acquire_friends(target_user))
    }

    # ツイートデータ収集
    t_tweet = Thread.start {
      puts_result_logs(UserTweetData.acquire_user_tweets(target_user))
    }

    # メンションデータ収集
    t_mentioned = Thread.start {
      puts_result_logs(MentionedTweetData.acquire_mentioned_tweets(target_user))
    }

    # ダイレクトメッセージデータ取得
    t_message = Thread.start {
      puts_result_logs(SendDirectMessage.acquire_all_send_message(target_user))
      puts_result_logs(ReceiveDirectMessage.acquire_all_send_message(target_user))
    }

    t_profile.join
    t_conn.join
    t_tweet.join
    t_mentioned.join
    puts "終了時刻 #{Time.now}"
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
