class AddSecretKeyToApps < ActiveRecord::Migration
  def change
    add_column    :apps, :secret_key, :string, :limit => 40
  end
end
