class ChangeStateToUser < ActiveRecord::Migration
  def change
      change_column :users, :state, :string
  end
end
