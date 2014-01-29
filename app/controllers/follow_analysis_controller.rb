class FollowAnalysisController < ApplicationController
  def index
    @my_followers = Follower.find_all_by_my_uid(login_my_uid)
  end
end
