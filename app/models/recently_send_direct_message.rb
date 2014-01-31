# -*- coding:utf-8 -*-
class RecentlySendDirectMessage < SendDirectMessage

  def self.acquire_recently_send_message(target_user,retry_control = nil)
    common_acquire(target_user, retry_control)
  end

  # ---------- テンプレートメソッド実装 ----------
  def self.build_option(my_uid, retry_control=nil)
    option = {}
    option[:count] = 200
    option[:since] = DirectMessage.send_max_id(my_uid)
    if retry_control
      option[:max_id] = retry_control.max_id
      return option
    else
      return option
    end
  end
end
