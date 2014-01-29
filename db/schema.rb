# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140128085259) do

  create_table "acquire_origins", :force => true do |t|
    t.string   "account_uid"
    t.string   "screen_name"
    t.string   "name"
    t.string   "location"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "acquire_origins", ["account_uid"], :name => "index_acquire_origins_on_account_uid", :unique => true

  create_table "batch_executions", :force => true do |t|
    t.string   "execute_log"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "batch_type"
  end

  create_table "data_acquisitions", :force => true do |t|
    t.string   "acquisition_log"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "followers", :force => true do |t|
    t.string   "my_uid"
    t.string   "follow_uid"
    t.string   "screen_name"
    t.string   "name"
    t.string   "location"
    t.string   "profile_image_url"
    t.text     "description"
    t.boolean  "is_follow"
    t.boolean  "is_followed"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "follower_count"
    t.integer  "friend_count"
  end

  add_index "followers", ["my_uid", "follow_uid"], :name => "index_followers_on_my_uid_and_follow_uid", :unique => true
  add_index "followers", ["my_uid"], :name => "index_followers_on_my_uid"

  create_table "tweet_data", :force => true do |t|
    t.string   "my_uid"
    t.string   "tweet_account_uid"
    t.integer  "tweet_id",          :limit => 255
    t.string   "tweet_text"
    t.datetime "tweet_at"
    t.integer  "rt_count"
    t.integer  "favorite_count"
    t.string   "parent_tweet_id"
    t.string   "tweet_type"
    t.boolean  "has_picture"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "tweet_data", ["my_uid", "tweet_id"], :name => "index_tweet_data_on_my_uid_and_tweet_id", :unique => true
  add_index "tweet_data", ["my_uid"], :name => "index_tweet_data_on_my_uid"
  add_index "tweet_data", ["tweet_account_uid"], :name => "index_tweet_data_on_tweet_account_uid"

  create_table "tweet_meta_infos", :force => true do |t|
    t.integer  "tweet_data_id"
    t.string   "meta_info_type"
    t.string   "account_uid"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "tweets", :force => true do |t|
    t.string   "my_uid"
    t.string   "tweet_id"
    t.string   "text"
    t.integer  "retweet_count"
    t.integer  "favorited_count"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "tweet_at"
    t.boolean  "may_burn"
    t.boolean  "checked",         :default => false
  end

  add_index "tweets", ["tweet_id"], :name => "index_tweets_on_tweet_id", :unique => true

  create_table "twitter_acquire_controls", :force => true do |t|
    t.string   "my_uid"
    t.string   "acquire_type"
    t.integer  "max_id"
    t.integer  "cursor"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "twitter_connections", :force => true do |t|
    t.string   "my_uid"
    t.string   "friend_uid"
    t.string   "screen_name"
    t.string   "name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.boolean  "is_follower",       :default => false
    t.boolean  "is_friend",         :default => false
    t.integer  "followers_count"
    t.integer  "friends_count"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "twitter_connections", ["my_uid", "friend_uid"], :name => "index_twitter_connections_on_my_uid_and_friend_uid", :unique => true
  add_index "twitter_connections", ["my_uid"], :name => "index_twitter_connections_on_my_uid"

  create_table "twitter_profiles", :force => true do |t|
    t.string   "my_uid"
    t.string   "name"
    t.text     "description",       :limit => 255
    t.string   "location"
    t.string   "profile_image_url"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "screen_name"
  end

  add_index "twitter_profiles", ["my_uid"], :name => "index_twitter_profiles_on_my_uid", :unique => true
  add_index "twitter_profiles", ["screen_name"], :name => "index_twitter_profiles_on_screen_name"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "uid",                    :default => "", :null => false
    t.string   "provider",               :default => "", :null => false
    t.string   "name"
    t.string   "access_token"
    t.string   "secret_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["uid", "provider"], :name => "index_users_on_uid_and_provider", :unique => true

end
