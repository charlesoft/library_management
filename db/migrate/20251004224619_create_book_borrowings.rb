class CreateBookBorrowings < ActiveRecord::Migration[7.1]
  def change
    create_table :book_borrowings do |t|
      t.references :book, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :borrowing_date, null: false
      t.date :due_date, null: false
      t.date :returned_date

      t.timestamps
    end
  end
end
