class DataAcquisitionController < ApplicationController
  def index
  end

  def delete_my_profile
    puts current_user.uid
    TwitterProfile.delete_all({my_uid: current_user.uid})
    redirect_to data_acquisition_index_path
  end

  def create_or_update_my_profile
    if TwitterProfile.exists?(my_uid: current_user.uid)
      get_profile_and_update(current_user.access_token, current_user.secret_token, current_user.uid)
    else
      get_profile_and_create(current_user.access_token, current_user.secret_token)
    end
    redirect_to data_acquisition_index_path
  end

  def create_or_update_my_followers
    #get_followers_and_create_or_update_followers(current_user.access_token, current_user.secret_token, login_my_uid)
    TwitterFollower.acquire_followers(current_user)
    TwitterFriend.acquire_friends(current_user)
    redirect_to data_acquisition_index_path
  end

  def create_my_tweet
    #tweets = get_my_tweet_and_create_or_update(current_user.access_token, current_user.secret_token, login_my_uid)
    UserTweetData.acquire_user_tweets(current_user)
    redirect_to data_acquisition_index_path
  end

  def create_my_recently_tweet
    RecentlyUserTweetData.acquire_recently_user_tweets(current_user)
    redirect_to data_acquisition_index_path
  end

  def create_my_retweet
    get_retweet_of_me(current_user.access_token, current_user.secret_token, login_my_uid)
    get_retweet_by_me(current_user.access_token, current_user.secret_token)
    redirect_to data_acquisition_index_path
  end

  def create_my_mention
    MentionedTweetData.acquire_mentioned_tweets(current_user)
    #get_mention_to_me(current_user.access_token, current_user.secret_token, login_my_uid)
    redirect_to data_acquisition_index_path
  end

  def create_my_recently_mention
    RecentlyMentionedTweetData.acquire_recently_mentioned_tweets(current_user)
    #get_mention_to_me(current_user.access_token, current_user.secret_token, login_my_uid)
    redirect_to data_acquisition_index_path
  end
end
