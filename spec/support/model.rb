require 'enumerize'
require 'wannabe_bool'
require 'booletania'

class User < ActiveRecord::Base
  has_one :profile, class_name: 'UserProfile'
  has_many :posts

  validates :account, presence: true
  validates :joined_at, presence: true
end

class UserProfile < ActiveRecord::Base
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :name, presence: true
end

class Post < ActiveRecord::Base
  extend Enumerize
  include Booletania

  enumerize :status, in: %i( wip protected published )

  belongs_to :user

  has_many :tags
end

class Tag < ActiveRecord::Base
  belongs_to :post

  validates :post_id, uniqueness: { scope: [:name] }
  validates :name, presence: true
end
