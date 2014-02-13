# -*- coding:utf-8 -*-
class AcquireOriginController< ApplicationController

  # 起点ユーザ収集画面初期表示
  def index
    puts "utudasinou AcquireOriginController index"

    # AcquireOriginテーブルのデータを取得
    @acquire_origins = AcquireOrigin.find_all_order_id_asc
    puts "@acquire_origins.count:#{@acquire_origins.count}"

    render :action => 'index'
  end

  # 起点ユーザ収集
  def acquire_origin_user
    puts "utudasinou acquire_origin_user"
    # ログインユーザのツイッターアカウント情報を取得
    target_user = User.get_user_data_by_uid(login_my_uid)

    # 起点ユーザを取得し、AcquireOriginテーブルに登録または更新する
    search_keyword = params[:search]
    puts search_keyword[:acquire_origin_searchword]
    result = AcquireOrigin.get_user_data(target_user, search_keyword[:acquire_origin_searchword])

    # AcquireOriginテーブルのデータを取得
    @acquire_origins = AcquireOrigin.find_all_order_id_asc

    if AcquireOrigin::RETURN_CODE_CREATE == result
      puts result
      message = '起点ユーザを追加しました'
    elsif AcquireOrigin::RETURN_CODE_UPDATE == result
      puts result
      message = '起点ユーザを更新しました'
    elsif AcquireOrigin::RETURN_CODE_NOTFOUND == result
      puts result
      message = 'アカウントが存在しません'
    end

    redirect_to '/acquire_origin/index', :notice => message
  end

end