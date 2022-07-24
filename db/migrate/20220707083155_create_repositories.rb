class CreateRepositories < ActiveRecord::Migration[7.0]
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :user
      t.string :latest_tag
      t.text :latest_release_notes

      t.timestamps
    end
  end
end
