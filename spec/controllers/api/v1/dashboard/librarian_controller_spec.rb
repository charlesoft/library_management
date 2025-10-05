require 'rails_helper'

RSpec.describe Api::V1::Dashboard::LibrarianController, type: :controller do
  routes { Rails.application.routes }
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:member_role) { UserRole.create!(name: 'member') }
  let!(:librarian_role) { UserRole.create!(name: 'librarian') }

  it 'returns totals and books due today for librarian' do
    librarian = User.create!(name: 'L', email: 'lib@example.com', password: 'password123', password_confirmation: 'password123', user_role: librarian_role)
    member = User.create!(name: 'M', email: 'mem@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
    book = Book.create!(title: 'Dune', author: 'Frank Herbert', genre: 'Sci-Fi', isbn: 'DL-1', total_copies: 1)
    BookBorrowing.create!(book: book, user: member, borrowing_date: Date.current - 1.day, due_date: Date.current)

    sign_in librarian
    get :show
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body['total_books']).to be >= 1
    expect(body['total_borrowed']).to be >= 1
    expect(body['books_due_today'].first['book']['id']).to eq(book.id)
  end

  it 'forbids member' do
    member = User.create!(name: 'M', email: 'mem2@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
    sign_in member
    get :show
    expect(response).to have_http_status(:forbidden)
  end
end


