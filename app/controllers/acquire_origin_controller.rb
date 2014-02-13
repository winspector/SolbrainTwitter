# -*- coding:utf-8 -*-
class AcquireOriginController< ApplicationController

  # 起点ユーザ収集画面初期表示
  def index
    puts "utudasinou AcquireOriginController index"

    # AcquireOriginテーブルのデータを取得
    @acquire_origins = AcquireOrigin.find_all_order_id_asc
    puts "@acquire_origins.count:#{@acquire_origins.count}"

    flash.now[:notice] = '起点ユーザ収集初期画面'
  end

  # 起点ユーザ収集
  def acquire_origin_user
    puts "utudasinou acquire_origin_user"
    # TODO ログインしているユーザのtwitterアカウント情報をUserテーブルから取得する
    target_user = User.find(2)

    # 起点ユーザを取得し、AcquireOriginテーブルに登録または更新する
    search_keyword = params[:search]
    puts search_keyword[:acquire_origin_searchword]
    @acquire_origin_user = AcquireOrigin.get_user_data(target_user, search_keyword[:acquire_origin_searchword])

    # AcquireOriginテーブルのデータを取得
    @acquire_origins = AcquireOrigin.find_all_order_id_asc

    render "index"
  end

end