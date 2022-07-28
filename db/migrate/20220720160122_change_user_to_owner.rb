class ChangeUserToOwner < ActiveRecord::Migration[7.0]
  def change
    rename_column :repositories, :user, :owner
  end
end
