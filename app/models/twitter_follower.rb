class TwitterFollower < TwitterConnection
  def self.acquire_followers(target_user)
    common_acquire(target_user)
  end

  # ----------- テンプレートメソッド実装 ----------
  def self.call_api_for_model(client, option)
    client.followers(option)
  end

  def self.create_hash_from_single_record(my_uid, single_record)
    result = super(my_uid, single_record)
    result[:is_follower] = true
    if single_record[:following].to_s == 'true'
      result[:is_friend] = true
    else
      result[:is_friend] = false
    end
    result
  end
end