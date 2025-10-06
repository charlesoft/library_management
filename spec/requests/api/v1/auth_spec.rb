require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  let!(:member_role) { UserRole.create!(name: 'member') }

  describe 'POST /api/v1/auth (sign up)' do
    it 'registers a user and returns JWT' do
      params = {
        user: {
          name: 'Alice',
          email: 'alice@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }

      post '/api/v1/auth', params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(response.headers['Authorization']).to be_present
      
      user = User.find_by(email: 'alice@example.com')
      
      body = JSON.parse(response.body)
      expect(body['user']['email']).to eq(user.email)
    end
    
    it 'returns an error if the user already exists' do
      User.create!(
        name: 'Alice', email: 'alice@example.com', password: 'password123',
        password_confirmation: 'password123', user_role: member_role
      )
      
      params = {
        user: {
          name: 'Alice', 
          email: 'alice@example.com', 
          password: 'password123',
          password_confirmation: 'password123'
        }
      }

      post '/api/v1/auth', params: params, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Email has already been taken')
    end
  end

  describe 'POST /api/v1/auth/sign_in (login)' do
    let!(:user) do
      User.create!(
        name: 'Bob', email: 'bob@example.com', password: 'password123',
        password_confirmation: 'password123', user_role: member_role
      )
    end

    it 'logs in and returns JWT' do
      params = { user: { email: 'bob@example.com', password: 'password123' } }
      
      post '/api/v1/auth/sign_in', params: params, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns an error if the email or password is incorrect' do
      params = { user: { email: 'bob@example.com', password: 'wrong_password' } }
      
      post '/api/v1/auth/sign_in', params: params, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('Invalid Email or password')
    end
  end

  describe 'DELETE /api/v1/auth/sign_out (logout)' do
    it 'revokes JWT on logout' do
      # Sign up to obtain a token
      post '/api/v1/auth', params: {
        user: {
          name: 'Carol', 
          email: 'carol@example.com', 
          password: 'password123',
          password_confirmation: 'password123'
        }
      }, as: :json

      token = response.headers['Authorization']
      expect(token).to be_present

      delete '/api/v1/auth/sign_out', headers: { 'Authorization' => token }, as: :json
      expect(response).to have_http_status(:ok)
    end
  end
end


