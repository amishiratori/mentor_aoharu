class CreateContributions < ActiveRecord::Migration[5.2]
  def change
    create_table :contributions do |t|
      t.string :image
      t.integer :like
      t.string :author
      t.references :mentor
    end
  end
end
