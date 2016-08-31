require 'activerecord-bixformer/version'
Dir["#{File.dirname(__FILE__)}/activerecord-bixformer/**/base.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/activerecord-bixformer/**/*.rb"].each { |f| require f }

module ActiveRecord
  module Bixformer
  end
end
