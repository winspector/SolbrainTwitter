class CreateDataAcquisitions < ActiveRecord::Migration
  def change
    create_table :data_acquisitions do |t|
      t.string :acquisition_log

      t.timestamps
    end
  end
end
