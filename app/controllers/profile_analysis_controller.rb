class ProfileAnalysisController < ApplicationController
  def index
    @profile = TwitterProfile.find_by_my_uid(login_my_uid)
  end
end
