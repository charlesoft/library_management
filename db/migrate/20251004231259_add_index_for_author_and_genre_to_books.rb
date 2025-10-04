class AddIndexForAuthorAndGenreToBooks < ActiveRecord::Migration[7.1]
  def change
    add_index :books, :author
    add_index :books, :genre
  end
end
