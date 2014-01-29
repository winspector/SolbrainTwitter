# -*- coding:utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  require "cgi"

  # ---------- twitter-api-client作成 ----------
  def rest_client(access_token, secret_token)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.configuration.twitter_consumer_key
      config.consumer_secret = Rails.configuration.twitter_secret_key
      config.access_token = access_token
      config.access_token_secret = secret_token
    end
  end

  # ---------- ユーザデータ取得 ----------
  def get_user_info(access_token, secret_token, account_uid)
    get_user_info_with_client(rest_client(access_token, secret_token), account_uid)
  end

  def get_user_info_with_client(client, account_uid)
    puts "target-uid:#{account_uid}"
    client.user(account_uid)
  end


  # ---------- プロフィールデータ取得 ----------
  def get_profile_and_create(access_token, secret_token)
    TwitterProfile.create(get_profile(access_token, secret_token))
  end

  def get_profile_and_update(access_token, secret_token, my_uid)
    profile = TwitterProfile.find_by_my_uid(my_uid)
    profile_data = get_profile(access_token, secret_token)
    profile_data.delete(:my_uid)
    profile_data.delete(:screen_name)
    puts profile_data
    profile.update_attributes(profile_data)
  end

  def get_profile(access_token, secret_token)
    client = rest_client(access_token, secret_token)
    get_profile_with_client(client)
  end

  def get_profile_with_client(client)
    @user = client.user
    return {my_uid: @user.id, screen_name: @user.screen_name, name: @user.name, location: @user.location, description: @user.description, profile_image_url: @user.profile_image_uri.to_s}
  end

  # ---------- フォロワーデータ取得関連 ----------
  def get_followers_and_create_or_update_followers(access_token, secret_token, my_uid)

    Follower.transaction do
      @followers = get_followers(access_token, secret_token)
      current_attr = @followers.attrs
      puts "attr #{current_attr.to_s}"
      puts "next_cursor #{@followers.attrs[:next_cursor].to_s}"
      @followers = get_followers(access_token, secret_token, nil, cursor:@followers.attrs[:next_cursor])
      current_attr = @followers.attrs
      puts "attr #{current_attr.to_s}"
      puts "next_cursor #{@followers.attrs[:next_cursor].to_s}"
      @followers.each do |follower|
        if Follower.exists?({my_uid: my_uid, follow_uid: follower.id})
          local_follower = Follower.find_by_my_uid_and_follow_uid(my_uid, follower.id)
          follower_data = {screen_name: follower.screen_name, name: follower.name, location: follower.location, description: follower.description, profile_image_url: follower.profile_image_uri.to_s, is_followed: true}
          local_follower.update_attributes(follower_data)
        else
          follower_data = {my_uid: my_uid, follow_uid: follower.id, screen_name: follower.screen_name, name: follower.name, location: follower.location, description: follower.description, profile_image_url: follower.profile_image_uri.to_s, is_followed: true, is_follow: false}
          Follower.create(follower_data)
        end
      end

      @friends = get_friends(access_token, secret_token)
      @friends.each do |friend|
        if Follower.exists?({my_uid: my_uid, follow_uid: friend.id})
          local_friend = Follower.find_by_my_uid_and_follow_uid(my_uid, friend.id)
          friend_data = {screen_name: friend.screen_name, name: friend.name, location: friend.location, description: friend.description, profile_image_url: friend.profile_image_uri.to_s, is_follow: true}
          local_friend.update_attributes(friend_data)
        else
          friend_data = {my_uid: my_uid, follow_uid: friend.id, screen_name: friend.screen_name, name: friend.name, location: friend.location, description: friend.description, profile_image_url: friend.profile_image_uri.to_s, is_followed: false, is_follow: true}
          Follower.create(friend_data)
        end
      end
    end
  end

  def get_target_followers(access_token, secret_token, target_user_id)
    Follower.transaction do
      @followers = get_followers(access_token, secret_token, target_user_id)
      @followers.each do |follower|
        if Follower.exists?({my_uid: my_uid, follow_uid: follower.id})
          local_follower = Follower.find_by_my_uid_and_follow_uid(my_uid, follower.id)
          follower_data = {screen_name: follower.screen_name, name: follower.name, location: follower.location, description: follower.description, profile_image_url: follower.profile_image_uri.to_s, is_followed: true, follower_count: follower.followers_count, friend_count: follower.friends_count}
          local_follower.update_attributes(follower_data)
        else
          follower_data = {my_uid: my_uid, follow_uid: follower.id, screen_name: follower.screen_name, name: follower.name, location: follower.location, description: follower.description, profile_image_url: follower.profile_image_uri.to_s, is_followed: true, is_follow: false, follower_count: follower.followers_count, friend_count: follower.friends_count}
          Follower.create(follower_data)
        end
      end

      @friends = get_friends(access_token, secret_token, target_user_id)
      @friends.each do |friend|
        if Follower.exists?({my_uid: my_uid, follow_uid: friend.id})
          local_friend = Follower.find_by_my_uid_and_follow_uid(my_uid, friend.id)
          friend_data = {screen_name: friend.screen_name, name: friend.name, location: friend.location, description: friend.description, profile_image_url: friend.profile_image_uri.to_s, is_follow: true, follower_count: follower.followers_count, friend_count: follower.friends_count}
          local_friend.update_attributes(friend_data)
        else
          friend_data = {my_uid: my_uid, follow_uid: friend.id, screen_name: friend.screen_name, name: friend.name, location: friend.location, description: friend.description, profile_image_url: friend.profile_image_uri.to_s, is_followed: false, is_follow: true, follower_count: follower.followers_count, friend_count: follower.friends_count}
          Follower.create(friend_data)
        end
      end
    end
  end

  def get_followers(access_token, secret_token, target_user_id = nil,option={})
    get_followers_with_client(rest_client(access_token, secret_token), target_user_id, option)
  end

  def get_followers_with_client(client, target_user_id, option={})
    if target_user_id
      client.followers(target_user_id,option)
    else
      client.followers(option)
    end
  rescue Twitter::Error::TooManyRequests => exception
    puts 'rate-limitにかかったもよう'
    puts "message:#{exception.message}"
    []
  end

  def get_friends(access_token, secret_token, target_user_id = nil)
    get_friends_with_client(rest_client(access_token, secret_token), target_user_id)
  end

  def get_friends_with_client(client, target_user_id)
    puts target_user_id
    if target_user_id
      client.friends(target_user_id)
    else
      client.friends
    end
  rescue Twitter::Error::TooManyRequests => exception
    puts 'rate-limitにかかったもよう'
    puts "message:#{exception.message}"
    []
  end

  # ---------- Tweetデータ取得関連 ----------
  def get_my_tweet_and_create_or_update(access_token, secret_token, my_uid)
    tweets = get_user_tweet_with_client(rest_client(access_token, secret_token))
    Tweet.create_or_update_for_tweets(tweets, my_uid)
  end

  def get_user_tweet(access_token, secret_token, target_user_id)
    get_user_tweet_with_client(rest_client(access_token, secret_token), target_user_id)
  end

  def get_user_tweet_with_client(client, target_user_id = nil)
    if target_user_id
      client.user_timeline(target_user_id, {'count' => 20})
    else
      client.user_timeline({'count' => 200})
    end
  end

  def get_user_tweet_by_loop(access_token, secret_token, target_user_id)
    since_id = Tweet.max_id_of_user(@origin.account_uid)
    get_user_tweet_with_client_by_loop(rest_client(access_token, secret_token), target_user_id)
  end

  def get_user_tweet_with_client_by_loop(client, target_user_id, max_id = nil, since_id = nil)
    collect_with_max_id(client, target_user_id, max_id) do |max_id|
      options = {:count => 200, :include_rts => false}
      options[:max_id] = max_id unless max_id.nil?
      options[:since_id] = since_id unless since_id.nil?
      client.user_timeline(target_user_id, options)
    end
  end

  def collect_with_max_id(client, target_user_id, max_id = nil, collection = [], &block)
    response = yield max_id
    collection += response
    if response.empty?
      collection.flatten
    else
      collect_with_max_id(client, target_user_id, (response.last.id - 1), collection, &block)
    end
  end

  # ---------- ReTweetデータ取得関連 ----------
  def get_retweet_of_me(access_token, secret_token, my_uid)
    get_retweet_of_me_with_client(rest_client(access_token, secret_token), my_uid)
  end

  def get_retweet_of_me_with_client(client, my_uid)
    retweets = client.retweets_of_me
    puts 'retweet出力（of_me）'
    retweets.each do |retweet|
      puts "retweet:#{retweet.text}"
    end
  end

  def get_retweet_by_me(access_token, secret_token)
    get_retweet_by_me_with_client(rest_client(access_token, secret_token))
  end

  def get_retweet_by_me_with_client(client)
    retweets = client.retweeted_by_me
    puts 'retweet（by_me）出力'
    retweets.each do |retweet|
      puts "retweet:#{retweet.text}"
    end
  end

  # ---------- Mentionデータ取得関連 ----------
  def get_mention_to_me(access_token, secret_token, my_uid)
    get_mention_to_me_with_client(rest_client(access_token, secret_token), my_uid)
  end

  def get_mention_to_me_with_client(client, my_uid)
    mentions = client.mentions_timeline
    puts 'mention(to me)出力'
    mentions.each do |mention|
      puts "mention:#{mention.text}"
    end
  end

  # ---------- ツィート検索 ----------
  def tweet_data_acquire_with_condition(access_token, secret_token, condition)
    @tweets = search_tweet_with_client_and_condition(rest_client(access_token, secret_token), condition)
  end

  def search_tweet_with_client_and_condition(client, condition)
    q = 'q=' + condition['and_word'].gsub(/　/, ' ')
    if condition['or_word'].length != 0
      q = q + ' ' + condition['or_word'].gsub(/[ 　]/, ' OR ')
    end

    puts q
    options = {:count => 20}
    client.search(q, options)
  end

  def login_my_uid
    current_user.uid
  end

end
