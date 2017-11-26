class Job < ApplicationRecord

  has_many :matches
  has_many :users, through: :matches
  has_and_belongs_to_many :users

end
