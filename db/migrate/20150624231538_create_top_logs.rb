class CreateTopLogs < ActiveRecord::Migration
  def change
    create_table :top_logs do |t|
      t.string :comment

      t.timestamps null: false
    end
  end
end
