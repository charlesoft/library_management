require 'rails_helper'

RSpec.describe Book, type: :model do
  it 'is invalid without required attributes' do
    book = Book.new
    expect(book).not_to be_valid
    expect(book.errors[:title]).to be_present
    expect(book.errors[:author]).to be_present
    expect(book.errors[:genre]).to be_present
    expect(book.errors[:isbn]).to be_present
  end

  it 'defaults total_copies to 0' do
    book = Book.create!(title: 'The Hobbit', author: 'J.R.R. Tolkien', genre: 'Fantasy', isbn: 'ISBN-001')
    expect(book.total_copies).to eq(0)
  end

  it 'enforces isbn uniqueness' do
    Book.create!(title: 'A', author: 'B', genre: 'C', isbn: 'D')
    dup = Book.new(title: 'X', author: 'Y', genre: 'Z', isbn: 'D')
    expect(dup).not_to be_valid
    expect(dup.errors[:isbn]).to be_present
  end
end
