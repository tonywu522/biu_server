class AddPhoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string, index: true
  end
end