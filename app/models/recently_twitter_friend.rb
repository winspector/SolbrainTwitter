# -*- coding:utf-8 -*-
class RecentlyTwitterFriend < TwitterConnection
  def self.acquire_recently_friends(target_user)
    common_acquire(target_user)
  end
  # 最新データがアカウント数百件も増えることはないだろうからリトライはしない！！

  # ----------- テンプレートメソッド実装 ----------
  def self.create_or_update_single_page(my_uid, single_page_data)
    result = {:status => 'no_conflict'}
    # コネクション方向が同じもしくは双方向の重複データが発生したらそこで終わり
    single_page_data.each do |single_record|
      friend_uid = single_record[:id]
      if TwitterFollower.exists?(my_uid: my_uid, friend_uid: friend_uid)
        local_follower = TwitterFollower.find_by_my_uid_and_friend_uid(my_uid, friend_uid)
        if local_follower.is_follower == true
          result[:status] = 'exist_conflict'
          return result
        end
        # 方向性が違うデータであれば衝突とは見なさない
        local_follower.update_attributes(update_hash_from_single_record(single_record))
      else
        TwitterFollower.create(create_hash_from_single_record(my_uid,single_record))
      end
    end
    result
  end
end