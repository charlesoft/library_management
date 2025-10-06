class User < ApplicationRecord
  include Indestructible
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  belongs_to :user_role
  has_many :book_borrowings

  validates :user_role_id, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
end
