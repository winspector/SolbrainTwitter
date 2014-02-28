# -*- coding:utf-8 -*-
class TestFlotr2Controller < ApplicationController
  def index
    puts "utudasinou test_flotr2_controller index"

    @friend_count_array = []
    @followers_count_array = []

    # 古畠さん
    #@screen_name = "wakuwaku_segaru"

    # 高野さん
    @screen_name = "mtknnktm"

    # murashinさん
    @screen_name = "skyView2011"
    @uid =AcquireOrigin.get_acquire_origin_by_screen_name(@screen_name)[:account_uid]

    TwitterConnection.get_friends_count_of_acquire_uid(@uid).to_a.each do |frends_count|
      @friend_count_array.push(frends_count[:friends_count])
      @followers_count_array.push(frends_count[:followers_count])
    end

    render '/test_flotr2/index'
  end
end