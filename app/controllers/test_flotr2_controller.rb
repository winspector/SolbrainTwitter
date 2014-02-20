# -*- coding:utf-8 -*-
class TestFlotr2Controller < ApplicationController
  def index
    puts "utudasinou test_flotr2_controller index"

    @friend_count_array = []
    @followers_count_array = []

    #@screen_name = "wakuwaku_segaru"
    @screen_name = "mtknnktm"
    @uid =AcquireOrigin.get_acquire_origin_by_screen_name(@screen_name)[:account_uid]

    # murashinさんのuidを直うち
    TwitterConnection.get_friends_count_of_acquire_uid(@uid).to_a.each do |frends_count|
      puts "frends_count:#{frends_count[:friends_count]}"
      @friend_count_array.push(frends_count[:friends_count])
      @followers_count_array.push(frends_count[:followers_count])
    end

    render "/test_flotr2/index"
  end
end