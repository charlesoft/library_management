require 'rails_helper'

RSpec.describe Api::V1::Dashboard::LibrarianController, type: :controller do
  routes { Rails.application.routes }
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:member_role) { UserRole.create!(name: 'member') }
  let!(:librarian_role) { UserRole.create!(name: 'librarian') }

it 'returns totals, books due today, and overdue members for librarian' do
  librarian = User.create!(name: 'L', email: 'lib@example.com', password: 'password123', password_confirmation: 'password123', user_role: librarian_role)
  member_one = User.create!(name: 'M1', email: 'm1@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
  member_two = User.create!(name: 'M2', email: 'm2@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
  book_one = Book.create!(title: 'B1', author: 'A', genre: 'G', isbn: 'LB-1', total_copies: 3)
  book_two = Book.create!(title: 'B2', author: 'A', genre: 'G', isbn: 'LB-2', total_copies: 5)

  # Due today (active)
  BookBorrowing.create!(book: book_one, user: member_one, borrowing_date: Date.current - 1.day, due_date: Date.current)
  # Overdue (active)
  BookBorrowing.create!(book: book_two, user: member_one, borrowing_date: Date.current - 5.days, due_date: Date.current - 2.days)
  # Overdue but returned late (still counts as overdue)
  BookBorrowing.create!(book: book_one, user: member_two, borrowing_date: Date.current - 6.days, due_date: Date.current - 3.days, returned_date: Date.current - 1.day)
  # Not overdue (active)
  BookBorrowing.create!(book: book_two, user: member_two, borrowing_date: Date.current - 1.day, due_date: Date.current + 5.days)
  # Returned early (should NOT count as overdue)
  BookBorrowing.create!(book: book_one, user: member_two, borrowing_date: Date.current - 2.days, due_date: Date.current + 1.day, returned_date: Date.current)

  sign_in librarian
  
  get :show
  
  expect(response).to have_http_status(:ok)
  body = JSON.parse(response.body)

  # Totals
  expect(body['total_books']).to eq(8)
  expect(body['total_borrowed']).to eq(3) # today + overdue_active + ok (nil returned_date)

  # Books due today contains the expected borrowing
  expect(body['books_due_today']).to be_an(Array)
  expect(body['books_due_today'].any? { |row| row['book']['id'] == book_one.id && row['borrowing']['due_date'] == Date.current.to_s }).to be(true)

  # Overdue members
  overdue_members = body['overdue_members']
  expect(overdue_members).to be_an(Array)
  
  # Find entries by member name
  m1_entry = overdue_members.find { |e| e['user']['id'] == member_one.id }
  m2_entry = overdue_members.find { |e| e['user']['id'] == member_two.id }
  
  expect(m1_entry).not_to be_nil
  expect(m2_entry).not_to be_nil
  # Books contain correct book, due dates and returned dates
  expect(m1_entry['books'].any? { |it| it['book']['id'] == book_two.id && it['due_date'] == (Date.current - 2.days).to_s && it['returned_date'].nil? }).to be(true)
  expect(m2_entry['books'].any? { |it| it['book']['id'] == book_one.id && it['due_date'] == (Date.current - 3.days).to_s && it['returned_date'] == (Date.current - 1.day).to_s }).to be(true)
end

  it 'forbids member' do
    member = User.create!(name: 'M', email: 'mem2@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
    
    sign_in member
    
    get :show
    expect(response).to have_http_status(:forbidden)
  end
end


