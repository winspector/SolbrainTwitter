class AcquireOrigin < ActiveRecord::Base
  attr_accessible :account_uid, :description, :location, :name, :screen_name
  
  def self.create_with_user_data(user)
    origin = {account_uid: user.id, screen_name: user.screen_name, name: user.name, location: user.location, description: user.description}
    AcquireOrigin.create(origin)
  end
end
