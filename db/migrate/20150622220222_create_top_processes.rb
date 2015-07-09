class CreateTopProcesses < ActiveRecord::Migration
  def change
    create_table :top_processes do |t|
      t.string :header
      t.integer :pid
      t.string :user
      t.integer :pr
      t.integer :ni
      t.integer :virt
      t.integer :res
      t.string :shr
      t.string :s
      t.float :cpu_usage
      t.float :mem_usage
      t.float :time_usage
      t.string :command

      t.timestamps null: false
    end
  end
end
