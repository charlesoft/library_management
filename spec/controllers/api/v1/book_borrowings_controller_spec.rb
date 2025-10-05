require 'rails_helper'

RSpec.describe Api::V1::BookBorrowingsController, type: :controller do
  routes { Rails.application.routes }
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:member_role) { UserRole.create!(name: 'member') }
  let!(:librarian_role) { UserRole.create!(name: 'librarian') }
  
  let(:user) { User.create!(name: 'M', email: 'm@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role) }

  describe 'POST create' do
    before do
      sign_in user
    end
    
    it 'creates a borrowing for a member when available' do
      book = Book.create!(title: 'Dune', author: 'Frank Herbert', genre: 'Sci-Fi', isbn: 'Z-1', total_copies: 1)
      
      post :create, params: { book_id: book.id, book_borrowing: { due_date: Date.current + 14.days } }
      
      expect(response).to have_http_status(:created)
      
      book_borrowing = BookBorrowing.last
      
      body = JSON.parse(response.body)
      expect(body['borrowing_date']).to eq(book_borrowing.borrowing_date.to_s)
      expect(body['due_date']).to eq(book_borrowing.due_date.to_s)
    end
    
    it "returns an error when due date is before borrowing date" do
      book = Book.create!(title: 'Hobbit', author: 'Tolkien', genre: 'Fantasy', isbn: 'Z-2', total_copies: 1)
      
      post :create, params: { book_id: book.id, book_borrowing: { due_date: Date.current - 14.days } }
      
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)['errors']).to include('Due date must be after borrowing date')
    end
    
    it "allows librarian to borrow the same book twice" do
      book = Book.create!(title: 'Hobbit', author: 'Tolkien', genre: 'Fantasy', isbn: 'Z-2', total_copies: 2)
      BookBorrowing.create!(book: book, user: user, borrowing_date: Date.current, due_date: Date.current + 14.days)
      
      librarian_user = User.create!(name: 'L', email: 'l@example.com', password: 'password123', password_confirmation: 'password123', user_role: librarian_role)
      
      sign_in librarian_user
      post :create, params: { book_id: book.id, book_borrowing: { due_date: Date.current + 14.days } }
      
      expect(response).to have_http_status(:created)
    end
    
    it "rejects borrowing the same book twice for member" do
      book = Book.create!(title: 'Hobbit', author: 'Tolkien', genre: 'Fantasy', isbn: 'Z-2', total_copies: 1)
      BookBorrowing.create!(book: book, user: user, borrowing_date: Date.current, due_date: Date.current + 14.days)
      
      post :create, params: { book_id: book.id, book_borrowing: { due_date: Date.current + 14.days } }
      
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)['errors']).to include('already borrowed this book')
    end

    it 'rejects when no copies are available' do
      book = Book.create!(title: 'Hobbit', author: 'Tolkien', genre: 'Fantasy', isbn: 'Z-2', total_copies: 0)

      post :create, params: { book_id: book.id, book_borrowing: { due_date: Date.current + 14.days } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)['errors']).to include('Book is not available')
    end
  end

  describe 'PATCH return_book' do
    it "allows librarian to mark a book as returned" do
      book = Book.create!(title: 'Hobbit', author: 'Tolkien', genre: 'Fantasy', isbn: 'Z-2', total_copies: 1)
      librarian_user = User.create!(name: 'L', email: 'test@example.com', password: 'password123', password_confirmation: 'password123', user_role: librarian_role)
      borrowing = BookBorrowing.create!(book: book, user: user, borrowing_date: Date.current + 1.day, due_date: Date.current + 14.days)
      
      sign_in librarian_user
      patch :return_book, params: { id: borrowing.id }
      
      expect(response).to have_http_status(:ok)
      
      updated_borrowing = borrowing.reload
      expect(JSON.parse(response.body)['returned_date']).to eq(updated_borrowing.returned_date.to_s)
    end

    it "does not allow member to mark a book as returned" do
      member_user = User.create!(name: 'M', email: 'member@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
      book = Book.create!(title: 'Hobbit', author: 'Tolkien', genre: 'Fantasy', isbn: 'Z-2', total_copies: 1)
      borrowing = BookBorrowing.create!(book: book, user: user, borrowing_date: Date.current, due_date: Date.current + 14.days)
      
      sign_in member_user
      patch :return_book, params: { id: borrowing.id }
      
      expect(response).to have_http_status(:forbidden)
    end
  end
end


