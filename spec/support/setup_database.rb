ActiveRecord::Base.configurations = {'test' => {adapter: 'sqlite3', database: ':memory:'}}
ActiveRecord::Base.establish_connection :test

class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name, null: false
    end
    add_index :groups, :name, unique: true

    create_table :users do |t|
      t.integer :group_id
      t.string :account, null: false
      t.datetime :joined_at, null: false
    end
    add_index :users, :account, unique: true

    create_table :user_profiles do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.string :email
      t.integer :age
    end
    add_index :user_profiles, :user_id, unique: true

    create_table :posts do |t|
      t.integer :user_id, null: false
      t.text :content
      t.string :status, null: false
      t.boolean :secret, null: false, default: true
    end

    create_table :tags do |t|
      t.integer :post_id, null: false
      t.string :name, null: false
    end
    add_index :tags, [:post_id, :name], unique: true
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up
