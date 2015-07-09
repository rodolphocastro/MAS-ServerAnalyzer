class AddTopFileToTopLogs < ActiveRecord::Migration
  def change
    add_column :top_logs, :top_file, :string
  end
end
