require 'enumerize'
require 'wannabe_bool'
require 'booletania'

class User < ActiveRecord::Base
  has_one :profile, class_name: 'UserProfile'
  has_many :posts

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :posts

  validates :account, presence: true, uniqueness: true
  validates :joined_at, presence: true
end

class UserProfile < ActiveRecord::Base
  self.primary_key = :user_id

  belongs_to :user

  validates :name, presence: true
end

class Post < ActiveRecord::Base
  extend Enumerize
  include Booletania

  enumerize :status, in: %i( wip protected published )

  belongs_to :user

  has_many :tags

  accepts_nested_attributes_for :tags
end

class Tag < ActiveRecord::Base
  belongs_to :post

  validates :post_id, uniqueness: { scope: [:name] }
  validates :name, presence: true
end
