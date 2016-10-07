require 'enumerize'
require 'wannabe_bool'
require 'booletania'

class Group < ActiveRecord::Base
  has_many :users

  validates :name, presence: true, uniqueness: { scope: [:kind] }, format: /\A[a-zA-Z0-9_]+\z/

  scope :admins, -> { where(kind: 'admin') }
end

class User < ActiveRecord::Base
  belongs_to :group

  has_one :profile, class_name: 'UserProfile', dependent: :destroy
  has_many :posts, dependent: :destroy

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :posts

  validates :account, presence: true, uniqueness: true
  validates :joined_at, presence: true
end

class UserProfile < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true
end

class Post < ActiveRecord::Base
  extend Enumerize
  include Booletania

  enumerize :status, in: %i( wip protected published )

  belongs_to :user

  has_many :tags, dependent: :destroy

  accepts_nested_attributes_for :tags

  validates :status, inclusion: { in: status.values }
end

class Tag < ActiveRecord::Base
  belongs_to :post

  validates :post_id, uniqueness: { scope: [:name] }
  validates :name, presence: true, length: { maximum: 5 }
end
