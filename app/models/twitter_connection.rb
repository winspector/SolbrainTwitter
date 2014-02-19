# -*- coding:utf-8 -*-
class TwitterConnection < ActiveRecord::Base
  require 'twitter_data_acquire_module'
  extend TwitterDataAcquireModule
  attr_accessible :description, :followers_count, :friend_uid,
                  :friends_count, :is_follower, :is_friend,
                  :location, :my_uid, :name, :profile_image_url, :screen_name

  # データ登録・更新
  def self.create_or_update_single_page(my_uid, single_page_data)
    single_page_data.each do |single_record|
      friend_uid = single_record[:id]
      if TwitterFollower.exists?(my_uid: my_uid, friend_uid: friend_uid)
        local_follower = TwitterFollower.find_by_my_uid_and_friend_uid(my_uid, friend_uid)
        local_follower.update_attributes(update_hash_from_single_record(single_record))
      else
        TwitterFollower.create(create_hash_from_single_record(my_uid, single_record))
      end
    end
  end

  # ---------- テンプレートメソッド実装 ----------
  def self.build_option(my_uid, retry_control=nil)
    if retry_control
      option[:cursor] = retry_control.cursor
      return option
    else
      return {}
    end
  end

  def self.loop_target_from_api_result(api_result)
    # follower, friends共通
    api_result.attrs[:users]
  end

  def self.build_option_and_prepare_next_page(my_uid, api_result, retry_control)
    option = {}
    option[:cursor] = api_result.attrs[:next_cursor]
    option
  end

  def next_page_api_result(client, option)
    call_api_for_model(client, option)
  end

  def self.is_loop_continue(api_result, persist_result)
    # FollowerはTwitter::Cursorなので、次のページが空ページかどうかはAPIを打つ前に分かる
    true
  end

  def self.need_next_page(api_result, persist_result)
    # このクラスはAPI-rate-limitにかかるか、次が0件まで取るやつなので次ページ0件チェック（-> カーソルチェック）だけする
    api_result.attrs[:next_cursor] != 0
  end

  def self.update_retry_control(my_uid, api_result, retry_control)
    TwitterAcquireControl.create_or_update_control_with_cursor(retry_control, my_uid, 'all_connection', api_result.attrs[:next_cursor])
  end

  def self.finish_persist(result, retry_control)
    if retry_control
      if !result[:is_api_rate_limit] || !result[:exist_exception]
        retry_control.delete
        retry_control.save!
      end
    end
  end

  # ---------- データ整形 ----------
  def self.create_hash_from_single_record(my_uid, single_record)
    {:description => single_record[:description], :followers_count => single_record[:followers_count].to_i, :friend_uid => single_record[:id],
     :friends_count => single_record[:friends_count].to_i,
     :location => single_record[:location], :my_uid => my_uid, :name => single_record[:name], :profile_image_url => single_record[:profile_image_url].to_s,
     :screen_name => single_record[:screen_name]}
  end

  def self.update_hash_from_single_record(single_record)
    result = create_hash_from_single_record(nil, single_record)
    result.delete(:my_uid)
    result.delete(:friend_uid)
    result.delete(:screen_name)
    result
  end

  # ---------- 起点ユーザのフレンド取得 ----------
  # 起点ユーザのフレンド（フォロー）を取得する
  def self.exec_get_friend_of_acquire_user(target_user, acquire_user_screen_name)
    puts "utudasinou exec_get_friend_of_acquier_user"

    # clientオブジェクトを作成
    client = get_client_object(target_user)

    # 起点ユーザのフレンドID配列、フォロワーID配列、コネクションユーザオブジェクト配列を設定
    friend_ids_array = get_friend_ids_array(client, acquire_user_screen_name)
    follower_ids_array = get_follower_ids_array(client, acquire_user_screen_name)
    connection_users = get_connection_users(client, follower_ids_array, friend_ids_array)

    # 起点ユーザのフレンド（フォロー）のユーザ情報をテーブルに追加または更新
    create_or_update_friend_of_acquire_user(acquire_user_screen_name, connection_users, friend_ids_array, follower_ids_array)
  end

  # target_userからclientオブジェクトを作成する

  def self.get_client_object(target_user)
    # clientオブジェクトを作成
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.configuration.twitter_consumer_key
      config.consumer_secret = Rails.configuration.twitter_secret_key
      config.access_token = target_user.access_token
      config.access_token_secret = target_user.secret_token
    end
    return client
  end

  def self.get_friend_ids_array(client, acquire_user_screen_name)
    # 起点ユーザのフレンド（フォロー）のIDを、cursorで取得
    friend_ids = client.friend_ids(acquire_user_screen_name)
    return friend_ids.to_a
  end

  def self.get_follower_ids_array(client, acquire_user_screen_name)
    # 起点ユーザのフォロワーのIDを、cursorで取得
    follower_ids = client.follower_ids(acquire_user_screen_name)
    return follower_ids.to_a
  end

  def self.get_connection_users(client, follower_ids_array, friend_ids_array)
    # 起点ユーザのフォロワーのみのIDを抽出
    only_follower_ids_array = []
    only_follower_ids_array.concat(follower_ids_array)
    friend_ids_array.each do |friend_id|
      only_follower_ids_array.delete(friend_id)
    end

    # 起点ユーザのフォローとフォロワーのみのIDをコネクションに追加
    connection_array = []
    connection_array.concat(friend_ids_array)
    connection_array.concat(only_follower_ids_array)

    # コネクションのIDの配列から、user情報を取得
    loop_count = (connection_array.size - 1) / 100 + 1
    connection_users = []
    loop_count.times do
      ids_array_tmp = connection_array.pop(100)
      friend_users_tmp = client.users(ids_array_tmp)
      # userオブジェクトの配列で返ってくるため、friend_usersに追加する
      connection_users.concat(friend_users_tmp)
    end
    return connection_users
  end

  # フレンド（フォロー）をテーブルに追加または更新する
  def self.create_or_update_friend_of_acquire_user(acquire_user_screen_name, connection_users, friend_ids_array, follower_ids_array)
    puts "utudasinou create_or_update_friend_of_acquire_user connection_users.count:#{connection_users.count}"
    # friend_usersを走査
    transaction_count = 0
    TwitterConnection.transaction do
      connection_users.each do |connection_user|
        friend_flg = get_friend_flg(friend_ids_array, connection_user)
        follower_flg = get_follower_flg(follower_ids_array, connection_user)

        create_or_update_friend_user = get_create_or_update_friend_user(connection_user, follower_flg, friend_flg, acquire_user_screen_name)

        if TwitterConnection.exists?(my_uid: create_or_update_friend_user[:my_uid], friend_uid: create_or_update_friend_user[:friend_uid])
          # friend_userが既に存在していた場合、更新する
          update_friend_user = find_by_my_uid_and_friend_uid(create_or_update_friend_user[:my_uid], create_or_update_friend_user[:friend_uid])
          update_friend_user.update_attributes(create_or_update_friend_user)
        else
          # friend_userが存在しない場合、追加する
          TwitterConnection.create(create_or_update_friend_user)
        end
        transaction_count += 1
        if (transaction_count % 100) == 0
          after_commit
        end
      end
    end
  end

  # フレンドフラグ判定
  def self.get_friend_flg(friend_ids_array, connection_user)
    if friend_ids_array.index(connection_user.id) == nil
      return false
    else
      return true
    end
  end

  # フォロワーフラグ判定
  def self.get_follower_flg(follower_ids_array, connection_user)
    if follower_ids_array.index(connection_user.id) == nil
      return false
    else
      return true
    end
  end

  # 追加または更新するデータを作成する
  def self.get_create_or_update_friend_user(connection_user, follower_flg, friend_flg, acquire_user_screen_name)
    create_or_update_friend_user = {
        :description => connection_user.description,
        :followers_count => connection_user.followers_count,
        :friend_uid => connection_user.id,
        :friends_count => connection_user.friends_count,
        :is_follower => follower_flg,
        :is_friend => friend_flg,
        :location => connection_user.location,
        # 起点ユーザのID
        :my_uid => AcquireOrigin.get_acquire_origin_by_screen_name(acquire_user_screen_name).account_uid,
        :name => connection_user.name,
        :profile_image_url => connection_user.profile_background_image_url,
        :screen_name => connection_user.screen_name
    }
    return create_or_update_friend_user
  end

  def self.get_friend_of_acquire_users(acquire_uid)
    TwitterConnection.where('my_uid = ?', acquire_uid).order('id ASC')
  end

  def self.get_friend_of_acquire_users_limit(acquire_uid, threshold_follower_count, limit_num)
    TwitterConnection.where('is_follower = "t" AND is_friend = "t" AND my_uid = ? AND followers_count < ?', acquire_uid, threshold_follower_count).order('followers_count DESC').limit(limit_num)
  end


end
