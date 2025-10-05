class AddUniqueActiveBorrowIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :book_borrowings, [:book_id, :user_id], unique: true, where: "returned_date IS NULL", name: 'index_book_borrowings_on_book_user_active'
  end
end
