class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :genre, null: false
      t.string :isbn, null: false
      t.integer :total_copies, default: 0, null: false

      t.timestamps
    end
    add_index :books, :title, unique: true
    add_index :books, :isbn, unique: true
  end
end
