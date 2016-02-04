class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Associations
  has_many :sections
  has_many :votes
  has_many :comments

end
