# -*- coding:utf-8 -*-
class UserTweetDataController < ApplicationController
  # 起点ユーザのツイート表示画面に遷移する
  def show_tweet_of_acquire_origin
    puts "utudasinou show_tweet_of_acquire_origin"
    # ログインユーザのツイッターアカウント情報を取得
    target_user = User.get_user_data_by_uid(login_my_uid)

    # 選択された起点ユーザのツイートを取得しデータベースに追加または更新をする
    puts "params[:screen_name]:#{params[:screen_name]}"
    @search_screen_name = params[:screen_name]
    UserTweetData.exec_get_acquire_user_tweets(target_user, params[:screen_name])

    # 選択された起点ユーザのツイート情報を取得する
    account_uid = AcquireOrigin.get_acquire_origin_by_screen_name(params[:screen_name])
    puts account_uid[:account_uid]
    @tweet_data_count = TweetData.get_all_tweet_data_count_by_my_uid_and_tweet_account_uid(login_my_uid, account_uid[:account_uid])
    puts "@tweet_data_count:#{@tweet_data_count}"

    # 起点ユーザのツイート表示画面に遷移する
    render '/user_tweet_data/show_tweet_of_acquire_origin'
  end
end