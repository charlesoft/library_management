require 'rails_helper'

RSpec.describe Api::V1::BooksController, type: :controller do
  routes { Rails.application.routes }
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:member_role) { UserRole.create!(name: 'member') }
  let!(:librarian_role) { UserRole.create!(name: 'librarian') }

  describe 'GET index' do
    it 'lists and searches with pagination' do
      Book.create!(title: 'Dune', author: 'Frank Herbert', genre: 'Sci-Fi', isbn: 'X-1')
      Book.create!(title: 'The Hobbit', author: 'J.R.R. Tolkien', genre: 'Fantasy', isbn: 'X-2')
      user = User.create!(name: 'M', email: 'm@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)

      sign_in user
      get :index, params: { q: 'Hobbit', limit: 1, offset: 0 }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data'].first['title']).to eq('The Hobbit')
      expect(body['pagination']).to include('limit' => 1, 'offset' => 0)
    end
  end

  describe 'POST create' do
    it 'forbids member' do
      user = User.create!(name: 'M', email: 'm2@example.com', password: 'password123', password_confirmation: 'password123', user_role: member_role)
      sign_in user
      post :create, params: { book: { title: 'X', author: 'Y', genre: 'Z', isbn: 'A-1' } }
      expect(response).to have_http_status(:forbidden)
    end

    it 'allows librarian' do
      user = User.create!(name: 'L', email: 'l@example.com', password: 'password123', password_confirmation: 'password123', user_role: librarian_role)
      sign_in user
      post :create, params: { book: { title: 'X', author: 'Y', genre: 'Z', isbn: 'A-2' } }
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH update' do
    it 'updates for librarian' do
      book = Book.create!(title: 'Old', author: 'A', genre: 'G', isbn: 'B-1')
      user = User.create!(name: 'L', email: 'l2@example.com', password: 'password123', password_confirmation: 'password123', user_role: librarian_role)
      sign_in user
      patch :update, params: { id: book.id, book: { title: 'New' } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['title']).to eq('New')
    end
  end

  describe 'DELETE destroy' do
    it 'deletes for librarian' do
      book = Book.create!(title: 'Del', author: 'A', genre: 'G', isbn: 'B-2')
      user = User.create!(name: 'L', email: 'l3@example.com', password: 'password123', password_confirmation: 'password123', user_role: librarian_role)
      sign_in user
      delete :destroy, params: { id: book.id }
      expect(response).to have_http_status(:no_content)
      expect(Book.find_by(id: book.id)).to be_nil
    end
  end
end


