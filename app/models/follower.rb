# -*- coding:utf-8 -*-
class Follower < ActiveRecord::Base
  attr_accessible :description, :follow_uid, :is_follow, :is_followed, :location, :my_uid, :name, :profile_image_url, :screen_name, :follower_count, :friend_count

  def follow_status
    if is_follow && is_followed
      return '相互フォロー'
    elsif is_follow
      return 'フォローしている'
    else
      return 'フォローされてる'
    end
  end

  def self.create_or_update_followers(my_uid,followers)
    create_or_update_some_users(my_uid, followers) do |user_hash|
      user_hash[:is_followed] = true
    end
  end

  def self.create_or_update_friends(my_uid,friends)
    create_or_update_some_users(my_uid, friends) do |user_hash|
      user_hash[:is_follow] = true
    end
  end

  def self.create_or_update_some_users(my_uid, users, &block)
    users.each do |user|
      if Follower.exists?(my_uid:my_uid, follow_uid:user.id)
        local_follower = Follower.find_by_my_uid_and_follow_uid(my_uid, user.id)
        user_hash = user_hash_from_user_object(user)
        user_hash.delete(:follow_uid)
        user_hash.delete(:screen_name)
        yield(user_hash)
        local_follower.update_attributes(user_hash)
      else
        user_hash = user_hash_from_user_object(user)
        user_hash[:my_uid] = my_uid
        yield(user_hash)
        Follower.create(user_hash)
      end
    end
  end

  def self.user_hash_from_user_object(user)
    {follow_uid: user.id, screen_name: user.screen_name, name: user.name, location: user.location, description: user.description, profile_image_url: user.profile_image_uri.to_s, follower_count: user.followers_count, friend_count: user.friends_count}
  end

end
