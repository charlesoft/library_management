class AddSoftDeleteToAllTables < ActiveRecord::Migration[7.1]
  def change
    [:users, :user_roles, :books, :book_borrowings, :jwt_denylists].each do |table|
      add_column table, :deleted, :boolean, null: false, default: false
      add_column table, :deleted_at, :datetime
    end
  end
end
