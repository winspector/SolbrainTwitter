class AddColumnToBatchExecution < ActiveRecord::Migration
  def change
    add_column :batch_executions, :batch_type, :string
  end
end
