# -*- coding:utf-8 -*-
class TweetDataAcquireController < ApplicationController
  def index
  end

  def search
    @tweets = tweet_data_acquire_with_condition(current_user.access_token, current_user.secret_token, params['search'])
    puts "tweet #{@tweets.attrs}"
    @tweets = @tweets.attrs[:statuses]
    render 'index'
  end

  def add_target
    # 選択されたアカウントを起点ターゲットに追加する
    if !AcquireOrigin.exists?(account_uid:params['origin']['account_uid'])
      target_user = get_user_info(current_user.access_token, current_user.secret_token,params['origin']['screen_name'])
      @origin = AcquireOrigin.create_or_update_with_user_data(target_user)
    else
      @origin = AcquireOrigin.find_by_account_uid(params['origin']['account_uid'])
    end

    # 起点アカウントのフォロワーとフレンドを取得
    followers = get_followers(current_user.access_token, current_user.secret_token,@origin.screen_name)
    Follower.create_or_update_followers(@origin.account_uid, followers)
    friends = get_friends(current_user.access_token, current_user.secret_token,@origin.screen_name)
    Follower.create_or_update_friends(@origin.account_uid, friends)

    # その人の全ツィートを取得
    #tweet_all = get_user_tweet_by_loop(current_user.access_token, current_user.secret_token,@origin.screen_name)
    #Tweet.create_or_update_for_tweets(tweet_all, @origin.account_uid)

    redirect_to tweet_data_acquire_index_path,{notice:'起点ユーザを追加しました'}
  end
end
