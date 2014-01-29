class CreateBatchExecutions < ActiveRecord::Migration
  def change
    create_table :batch_executions do |t|
      t.string :execute_log

      t.timestamps
    end
  end
end
