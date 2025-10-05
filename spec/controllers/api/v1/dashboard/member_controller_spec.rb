require 'rails_helper'

RSpec.describe Api::V1::Dashboard::MemberController, type: :controller do
  routes { Rails.application.routes }
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:member_role) { UserRole.create!(name: 'member') }
  let!(:librarian_role) { UserRole.create!(name: 'librarian') }

  it "lists member's borrowings with overdue flag" do
    member = User.create!(name: 'M', email: 'mem3@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
    book1 = Book.create!(title: 'B1', author: 'A', genre: 'G', isbn: 'MB-1', total_copies: 2)
    book2 = Book.create!(title: 'B2', author: 'A', genre: 'G', isbn: 'MB-2', total_copies: 2)
    BookBorrowing.create!(book: book1, user: member, borrowing_date: Date.current - 3.days, due_date: Date.current - 1.day)
    BookBorrowing.create!(book: book2, user: member, borrowing_date: Date.current - 1.day, due_date: Date.current + 10.days)

    sign_in member
    get :show
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body['borrowings'].size).to eq(2)
    overdue_flags = body['borrowings'].map { |b| b['overdue'] }
    expect(overdue_flags).to include(true, false)
  end
end


