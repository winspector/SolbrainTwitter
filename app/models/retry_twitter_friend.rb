class RetryTwitterFriend < TwitterConnection
  def self.acquire_retry_friends(target_user)
    common_acquire(target_user)
  end
  # ----------- テンプレートメソッド実装 ----------
end