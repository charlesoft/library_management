require 'rails_helper'

RSpec.describe BookBorrowing, type: :model do
  let!(:role) { UserRole.create!(name: 'member') }
  let!(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123', password_confirmation: 'password123', user_role: role) }

  it 'requires borrowing_date and due_date' do
    book = Book.create!(title: 'The Hobbit', author: 'J.R.R. Tolkien', genre: 'Fantasy', isbn: 'ISBN-002')
    bb = BookBorrowing.new(book: book, user: user)
    
    expect(bb).not_to be_valid
    expect(bb.errors[:borrowing_date]).to be_present
    expect(bb.errors[:due_date]).to be_present
  end

  it 'is valid with required fields' do
    book = Book.create!(title: 'The Hobbit', author: 'J.R.R. Tolkien', genre: 'Fantasy', isbn: 'ISBN-002', total_copies: 1)
    bb = BookBorrowing.new(book: book, user: user, borrowing_date: Date.today, due_date: Date.today + 14)
    
    expect(bb).to be_valid
  end
end
