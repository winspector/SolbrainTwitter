class TwitterFriend < TwitterConnection
  def self.acquire_friends(target_user)
    common_acquire(target_user)
  end

  # ----------- テンプレートメソッド実装 ----------
  def self.call_api_for_model(client, option)
    client.friends(option)
  end

  def self.create_hash_from_single_record(my_uid, single_record)
    result = super(my_uid, single_record)
    result[:is_friend] = true
    result
  end
end