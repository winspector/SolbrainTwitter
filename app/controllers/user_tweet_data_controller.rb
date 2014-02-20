# -*- coding:utf-8 -*-
class UserTweetDataController < ApplicationController

  # 起点ユーザ詳細画面を表示する
  THRESHOLD_FOLLOWER_COUNT = 200

  # 集める起点ユーザの友人アカウント数
  FRIEND_NUM = 5

  def index
    puts "utudasinou index"

    # 起点ユーザの表示名を設定
    @search_screen_name = session[:screen_name]

    # 起点ユーザのツイート数を設定
    acquire_uid = AcquireOrigin.get_acquire_origin_by_screen_name(@search_screen_name)
    @tweet_data_count = TweetData.get_all_tweet_data_count_by_my_uid_and_tweet_account_uid(login_my_uid, acquire_uid[:account_uid])

    # 起点ユーザの友人を取得
    #@friend_of_acquire_users = TwitterConnection.get_friend_of_acquire_users(acquire_uid[:account_uid])
    @friend_of_acquire_users = TwitterConnection.get_friend_of_acquire_users_limit(acquire_uid[:account_uid], THRESHOLD_FOLLOWER_COUNT, FRIEND_NUM)
    #@friend_of_acquire_users = params[:account]
    #puts "params:#{params}"
    #puts "acount:#{params[:account]}"
    #
    #@friend_of_acquire_users = []
    #params[:account].each do |id|
    #  @friend_of_acquire_users.push(TwitterConnection.get_friend_by_id(id))
    #end

    #puts "@friend_of_acquire_users:#{@friend_of_acquire_users}"

    # 起点ユーザの友人のツイートを取得
    @friend_of_acquire_users.each do |friend_of_acquire_user|
      puts friend_of_acquire_user
      tweet_count = TweetData.get_all_tweet_data_count_by_my_uid_and_tweet_account_uid(friend_of_acquire_user.my_uid, friend_of_acquire_user.friend_uid)
      friend_of_acquire_user['tweet_count']=tweet_count
    end

    render "/user_tweet_data/index"
  end

  # 起点ユーザのツイート表示画面に遷移する
  def show_tweet_of_acquire_origin
    puts "utudasinou show_tweet_of_acquire_origin"
    # 起点ユーザの表示名をセッションに格納
    session[:screen_name]=params[:screen_name]

    # ログインユーザのツイッターアカウント情報を取得
    target_user = User.get_user_data_by_uid(login_my_uid)

    # 選択された起点ユーザのツイートを取得しデータベースに追加または更新をする
    UserTweetData.exec_get_acquire_user_tweets(target_user, params[:screen_name])

    # 選択された起点ユーザのフレンドを取得し、データベースに追加または更新をする
    TwitterConnection.exec_get_friend_of_acquire_user(target_user, params[:screen_name])

    # 選択された起点ユーザのフレンドからツイートデータを収集するユーザを抽出する
    acquire_uid = AcquireOrigin.get_acquire_origin_by_screen_name(params[:screen_name]).account_uid
    #target_acquire_friends = TwitterConnection.get_friend_of_acquire_users_limit(acquire_uid, THRESHOLD_FOLLOWER_COUNT, FRIEND_NUM)
    target_acquire_friends = TwitterConnection.get_friend_of_acquire_users_no_limit(acquire_uid, THRESHOLD_FOLLOWER_COUNT)

    puts "target_acquire_friends:#{target_acquire_friends.count}"
    account = UserTweetData.exec_get_acquire_friends_tweet_data(target_user, params[:screen_name], target_acquire_friends)
    puts "acount:#{account}"

    # 起点ユーザのツイート表示画面に遷移する
    redirect_to :action => 'index', :account => account
  end
end