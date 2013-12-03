class CreateApiWhitelists < ActiveRecord::Migration
  def change
    create_table :api_whitelists do |t|
      t.string :app_key
      t.string :version, :limit => 5
    end
    add_index "api_whitelists", ["app_key", "version"]
  end
end
