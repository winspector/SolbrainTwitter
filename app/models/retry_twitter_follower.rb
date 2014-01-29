class RetryTwitterFollower < TwitterFollower
  def self.acquire_retry_followers(target_user)
    common_acquire(target_user)
  end

  # ----------- テンプレートメソッド実装 ----------
end