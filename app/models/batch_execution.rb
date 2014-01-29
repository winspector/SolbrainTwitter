# -*- coding:utf-8 -*-
class BatchExecution < ActiveRecord::Base
  attr_accessible :execute_log, :batch_type

  def puts_result_logs(result)
    puts "初回収集バッチが完了しました status:#{result[:status]} message:#{result[:message]}"
  end
end
