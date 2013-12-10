class AddAuthlogicFieldToDevelopers < ActiveRecord::Migration
  def change
    add_column :developers, :email, :string
    add_column :developers, :crypted_password, :string
    add_column :developers, :password_salt, :string
    add_column :developers, :persistence_token, :string
  end
end
