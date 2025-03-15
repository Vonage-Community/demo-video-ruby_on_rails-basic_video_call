class AddStatusToVideoCalls < ActiveRecord::Migration[8.0]
  def change
    add_column :video_calls, :status, :string, default: 'active'
  end
end
