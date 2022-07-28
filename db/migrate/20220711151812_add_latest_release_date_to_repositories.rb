class AddLatestReleaseDateToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :latest_release_date, :datetime
  end
end
