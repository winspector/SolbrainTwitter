#-*- coding:utf-8 -*-
class DashboardController < ApplicationController
  before_filter :authenticate_user!
  def index
    puts current_user.access_token
    puts current_user.secret_token

    client = rest_client(current_user.access_token, current_user.secret_token)
    @timeline = client.home_timeline

    @user = client.user
    puts @user.id
    puts @user.screen_name
    puts @user.name
    puts @user.profile_image_uri
    puts @user.location
    puts @user.description
  end
end
