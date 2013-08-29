class AddAppIdToClientSessions < ActiveRecord::Migration
  def change
    add_column :client_sessions, :app_id, :integer
  end
end
