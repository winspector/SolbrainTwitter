# -*- coding:utf-8 -*-
class SendDirectMessage < DirectMessage

  def self.acquire_all_send_message(target_user,retry_control = nil)
    common_acquire(target_user, retry_control)
  end

  # ---------- テンプレートメソッド実装 ----------
  def self.call_api_for_model(client, option)
    client.direct_messages_sent(option)
  end

  def self.update_retry_control(my_uid, api_result, retry_control)
    last_id = api_result.last.id
    TwitterAcquireControl.create_or_update_control_with_max_id(retry_control, my_uid, 'all_send_message', last_id)
  end
end
