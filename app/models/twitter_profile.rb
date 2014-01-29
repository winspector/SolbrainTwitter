# -*- coding:utf-8 -*-
class TwitterProfile < ActiveRecord::Base
  require 'twitter_data_acquire_module'
  extend TwitterDataAcquireModule
  attr_accessible :description, :location, :my_uid, :name, :profile_image_url, :screen_name

  def self.acquire_profile(target_user)
    common_acquire(target_user, nil)
  end

  # ---------- テンプレートメソッド実装 ----------
  # プロフィールに次のページはいない
  def self.need_next_page(api_result, persist_result)
    false
  end

  def self.call_api_for_model(client, option)
    client.user
  end

  def self.create_or_update_single_page(my_uid, single_record_data)
    # プロフィールは1件しかこない
    if TwitterProfile.exists?(my_uid:single_record_data.id)
      # プロフィールがいれば更新
      local_profile = TwitterProfile.find_by_my_uid(single_record_data.id)
      local_profile.update_attributes(update_hash_from_single_record_data(single_record_data))
    else
      # プロフィールがいなければ新規登録
      TwitterProfile.create(create_hash_from_single_record_data(single_record_data))
    end
  end

  # ---------- メソッド群 ----------f
  def self.create_or_update_single_record(single_record_data)

    if TwitterProfile.exists?(my_uid:single_record_data.id)
      # プロフィールがいれば更新
      local_profile = TwitterProfile.find_by_my_uid(single_record_data.id)
      local_profile.update_attributes(update_hash_from_single_record_data(single_record_data))
    else
      # プロフィールがいなければ新規登録
      TwitterProfile.create(create_hash_from_single_record_data(single_record_data))
    end
  end

  def self.create_hash_from_single_record_data(single_record_data)
    return {my_uid: single_record_data.id,
            screen_name: single_record_data.screen_name,
            name: single_record_data.name,
            location: single_record_data.location,
            description: single_record_data.description,
            profile_image_url: single_record_data.profile_image_uri.to_s}
  end

  def self.update_hash_from_single_record_data(single_record_data)
    result = create_hash_from_single_record_data(single_record_data)
    result.delete(:my_uid)
    result.delete(:screen_name)
    result
  end

  def self.update_retry_control(my_uid,api_result,retry_control)
    # プロフィールでは何もすることなし
  end
end
