class User < ActiveRecord::Base
  has_secure_token :authentication_token
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  has_many :team_memberships
  has_many :teams, through: :team_memberships
end
