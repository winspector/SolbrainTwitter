class TwitterAcquireControl < ActiveRecord::Base
  attr_accessible :acquire_type, :cursor, :max_id, :my_uid

  def self.create_or_update_control_with_max_id(retry_control, my_uid, acquire_type, max_id)
    if !retry_control
      retry_control = TwitterAcquireControl.create({my_uid:my_uid, acquire_type:acquire_type, max_id:max_id})
    else
      retry_control.update_attribute(:max_id, max_id)
      retry_control.save!
    end
    retry_control
  end

  def self.create_or_update_control_with_cursor(retry_control, my_uid, acquire_type, cursor)
    if !retry_control
      retry_control = TwitterAcquireControl.create({my_uid:my_uid, acquire_type:acquire_type, cursor:cursor})
    else
      retry_control.update_attribute(:cursor,cursor)
      retry_control.save!
    end
    retry_control
  end
end
