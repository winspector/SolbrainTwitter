# -*- coding:utf-8 -*-
class UpdateTwitterConnection < TwitterConnection
  require 'twitter_data_acquire_module'
  extend TwitterDataAcquireModule
  attr_accessible :description, :followers_count, :friend_uid,
                  :friends_count, :is_follower, :is_friend,
                  :location, :my_uid, :name, :profile_image_url, :screen_name

  def self.update_connection(target_user,retry_control = nil)
    common_acquire(target_user,retry_control)
  end

  # データ登録・更新
  def self.create_or_update_single_page(my_uid, single_page_data)
    # まずコネクションステータスを更新
    single_page_data[:friendships].each do |friendship|
      friendship_status = {}
      friend_uid = friendship[:id]
      connections = friendship[:connections]
      if connections.length == 2
        friendship_status[:is_friend] = true
        friendship_status[:is_follower] = true
      elsif connections[0] == 'following'
        friendship_status[:is_friend] = true
      else
        friendship_status[:is_follower] = true
      end
      if TwitterFollower.exists?(my_uid: my_uid, friend_uid: friend_uid)
        local_follower = TwitterFollower.find_by_my_uid_and_friend_uid(my_uid, friend_uid)
        local_follower.update_attributes(friendship_status)
      end
    end

    # 次にユーザ情報を更新
    single_page_data[:users].each do |single_record|
      friend_uid = single_record[:id]
      if TwitterFollower.exists?(my_uid: my_uid, friend_uid: friend_uid)
        local_follower = TwitterFollower.find_by_my_uid_and_friend_uid(my_uid, friend_uid)
        local_follower.update_attributes(update_hash_from_single_record(single_record))
      else
        TwitterFollower.create(create_hash_from_single_record(my_uid,single_record))
      end
    end
  end

  # ---------- テンプレートメソッド実装 ----------
  def self.call_api_for_model(client, option)
    target_screen_names = option[:target_screen_names]
    option.delete(:target_screen_names)
    friendships = client.friendships(target_screen_names)
    users = client.users(target_screen_names, option)
    {users:users, friendships:friendships}
  end

  def self.build_option(my_uid, retry_control=nil)
    target_screen_names = []
    TwitterConnection.where('my_uid = ?',my_uid).order('updated_at ASC').limit(100).each do |target|
      target_screen_names << target.screen_name
    end
    #return {target_screen_names:target_screen_names, include_entities:true}
    return {target_screen_names:target_screen_names}
  end

  def self.loop_target_from_api_result(api_result)
    # friendshipsはそのままuserの配列
    api_result
  end

  def self.update_retry_control(my_uid, api_result, retry_control)
    # カーソル使わず毎回決まった人数だけ取ってくるのでretryという概念は無い
  end

  def self.finish_persist(result, retry_control)
    if retry_control
      if !result[:is_api_rate_limit] || !result[:exist_exception]
        retry_control.delete
        retry_control.save!
      end
    end
  end

  def self.need_next_page(api_result, persist_result)
    false
  end

  # ---------- データ整形 ----------
  def self.update_hash_from_single_record(single_record)
    super(single_record)
  end
end
