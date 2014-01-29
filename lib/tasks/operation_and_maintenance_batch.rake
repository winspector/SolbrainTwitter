# -*- coding:utf-8 -*-

namespace :maintenance do
  desc "特定の人物に紐づくデータを削除します"
  task :wipeout_data_by_user, :target_id
  task :wipeout_data_by_user => :environment do |t, args|

    # ターゲットユーザの取得
    user_id = args[:target_id]
    if !User.exists?(user_id.to_i)
      puts '存在しないユーザが指定されました'
    else
      target_user = User.find(user_id.to_i)
      target_uid = target_user.uid

      TwitterProfile.delete_all(['my_uid = ?', target_uid])
      TwitterFollower.delete_all(['my_uid = ?', target_uid])
      TwitterFriend.delete_all(['my_uid = ?', target_uid])
      TweetData.delete_all(['my_uid = ?', target_uid])
    end
  end
end