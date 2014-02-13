# -*- coding:utf-8 -*-
class AcquireOrigin < ActiveRecord::Base
  attr_accessible :account_uid, :description, :location, :name, :screen_name

  RETURN_CODE_CREATE = 0
  RETURN_CODE_UPDATE = 1
  RETURN_CODE_NOTFOUND = 2
  # screen nameから、与えられたユーザの情報を取得し起点テーブルに挿入する
  def self.get_user_data(target_user, search_key)
    puts "search_key:#{search_key}"
    result = RETURN_CODE_NOTFOUND

    # clientオブジェクトを作成する
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.configuration.twitter_consumer_key
      config.consumer_secret = Rails.configuration.twitter_secret_key
      config.access_token = target_user.access_token
      config.access_token_secret = target_user.secret_token
    end

    # clientからuserメソッドを使い、search_keyのユーザを取得する
    if client.user?(search_key)
      puts 'imasu'
      acquire_user = client.user(search_key)

      result = create_or_update_with_user_data(acquire_user)
    else
      puts 'imasen'
      result = RETURN_CODE_NOTFOUND
    end
  end

  # 起点ユーザテーブルにユーザを登録する、または更新する
  def self.create_or_update_with_user_data(user)
    # 起点ユーザテーブルに登録するユーザオブジェクトを作成
    acquire_user = {
        :account_uid => user.id,
        :description => user.description,
        :location => user.location,
        :name => user.name,
        :screen_name => user.screen_name
    }

    # 起点ユーザテーブルにユーザデータがあるか確認
    if AcquireOrigin.exists?(account_uid:acquire_user[:account_uid])
      puts 'sudeni imasu'
      # 更新ユーザを取得
      update_user = AcquireOrigin.find_by_account_uid(acquire_user[:account_uid])

      # 起点ユーザテーブルの起点ユーザを更新
      update_user.update_attributes(acquire_user)
      return RETURN_CODE_UPDATE
    else
      # 起点ユーザテーブルに起点ユーザを登録
      AcquireOrigin.create(acquire_user)
      return RETURN_CODE_CREATE
    end
  end

  # 起点ユーザテーブルにユーザが存在するか確認する
  def self.is_aqcquire_user(acquire_user)
    if 0 != AcquireOrigin.where('account_uid = ?', acquire_user[:account_uid]).count
      # 起点ユーザテーブルにユーザが存在する
      return true
    else
      return false
    end
  end

  def self.find_all_order_id_asc
    AcquireOrigin.order('id ASC')
  end

  def self.get_acquire_origin_by_screen_name(screen_name)
    AcquireOrigin.find_by_screen_name(screen_name)
  end

end
