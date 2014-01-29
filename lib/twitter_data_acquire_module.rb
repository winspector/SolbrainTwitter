# -*- coding:utf-8 -*-
module TwitterDataAcquireModule
  def common_acquire(target_user, retry_control = nil)
    result = {}
    # クライアント取得
    client = rest_client_from_analysis_user(target_user)

    my_uid = target_user.uid

    if !client
      puts "Twitterクライアントの作成に失敗したので取得処理を中断します #{target_user.id}"
      result[:message] = 'apiクライアントの作成に失敗しました'
      result[:status] = 'error'
      return result
    end

    option = build_option(my_uid, retry_control)

    # api コール
    call_api_result = call_api(client, option)

    if !call_api_result
      puts "apiコール初回で失敗したので取得処理を中断します #{target_user.id}"
      result[:message] = 'apiコールに初回失敗しました'
      result[:status] = 'error'
      return result
    elsif call_api_result.kind_of?(Array) && call_api_result.length == 0
      puts 'apiコール初回結果が0件でしたので取得処理を終了します'
      result[:message] = 'api初回コールの結果が0件でした'
      result[:status] = 'warning'
      return result
    end

    # データ登録
    result_persist = create_or_update_with_api_result(my_uid, call_api_result, client)
    if result_persist[:is_api_rate_limit]
      result[:message] = 'レートリミットにぶつかったようです'
      result[:status] = 'warning'
    elsif result_persist[:exist_exception]
      result[:message] = 'なにか不具合があったようです'
      result[:status] = 'error'
    end
    result
  end


  def call_api(client, option)
    call_api_for_model(client, option)
  rescue => exception
    puts_exception_log(exception)
    nil
  end


  def create_or_update_with_api_result(my_uid, api_result, client, retry_control = nil)
    result = {is_api_rate_limit: false, exist_error: false}
    continue_loop = false
    begin
      loop_target = loop_target_from_api_result(api_result)
      persist_result = nil
      TwitterProfile.transaction do
        persist_result = create_or_update_single_page(my_uid, loop_target)
      end

      # 1P分登録し終わったらRetryデータの更新
      update_retry_control(my_uid, api_result, retry_control)

      if need_next_page(api_result, persist_result)
        option = build_option_and_prepare_next_page(my_uid, api_result, retry_control)
        api_result = call_api_for_model(client, option)
        # 次のページを取得した結果ループを続けるか判断
        continue_loop = is_loop_continue(api_result, persist_result)
      else
        continue_loop = false
      end
    rescue Twitter::Error::TooManyRequests => exception
      puts_exception_log exception
      handling_result = handling_exception_with_paging(exception)
      continue_loop = handling_result[:continue_loop]
      result[:is_api_rate_limit] = true
      # 例外が発生したら無条件break
      break
    rescue => exception
      puts 'api-rate-limitでないなんかの例外'
      puts_exception_log exception
      # 例外が発生したら無条件break
      break
      result[:exist_exception] = true
    end while (continue_loop)

    finish_persist(result, retry_control)
    result
  end

  def puts_exception_log(exception)
    puts exception.message
    puts exception.backtrace
  end

  # ---------- RESTクライアント取得 ----------
  def rest_client_from_analysis_user(analysis_user)
    rest_client(analysis_user.access_token, analysis_user.secret_token)
  rescue => exception
    puts_exception_log(exception)
    nil
  end

  def rest_client(access_token, secret_token)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.configuration.twitter_consumer_key
      config.consumer_secret = Rails.configuration.twitter_secret_key
      config.access_token = access_token
      config.access_token_secret = secret_token
    end
    client
  end

  # ---------- 継承先実装メソッド ----------
  def build_option(my_uid, retry_control=nil)
    # デフォルトは値無し
    {}
  end

  def call_api_for_model(client, option)
    raise NotImplementedError, "#{__method__}が実装されていません"
  end

  def handling_exception_with_api_call(exception)
    puts 'api-call時の例外処理だけどなんも実装されてません'
  end

  def handling_exception_with_paging(exception, option={})
    # デフォルトはなんもしない&&ループ中断設定
    puts 'paging時の例外処理だけどなんも実装されてません'
    {continue_loop: false}
  end

  def create_or_update_single_page(my_uid, single_record_data)
    raise NotImplementedError, "#{__method__}が実装されていません"
  end

  def loop_target_from_api_result(api_result)
    # デフォルトはなんもなし（Array<Twitter::Tweet>）みたいな場合
    # Twitter::Cursorとかだとattrsする必要あり
    api_result
  end

  def update_retry_control(my_uid, api_result, retry_control)
    raise NotImplementedError, "#{__method__}が実装されていません"
  end

  def next_page_api_result(client, option)
    raise NotImplementedError, "#{__method__}が実装されていません"
  end

  # カーソル方式などAPIを実行する前に次を取るかどうか分かる場合に利用するチェックメソッド
  def need_next_page(api_result, persist_result)
    #デフォルトはtrue（常に次のPをとる）
    true
  end

  def is_loop_continue(api_result, persist_result)
    raise NotImplementedError, "#{__method__}が実装されていません"
  end

  def build_option_and_prepare_next_page(my_uid, api_result, retry_control)
    raise NotImplementedError, "#{__method__}が実装されていません"
  end

  def next_page_option_add_only_max_id(my_uid, max_id)
    option = build_option(my_uid)
    option[:max_id] = max_id
    option
  end

  def finish_persist(result, retry_control)
    # デフォルトはなんもしない
  end
end