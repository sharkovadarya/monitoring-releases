class AddReadToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :read, :boolean
  end
end
