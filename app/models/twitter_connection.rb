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
        TwitterFollower.create(create_hash_from_single_record(my_uid,single_record))
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
end
