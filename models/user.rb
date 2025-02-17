# models/user.rb

require "sinatra/activerecord"
require "bcrypt"

class User < ActiveRecord::Base
  has_secure_password
  has_many :bookmarks, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
