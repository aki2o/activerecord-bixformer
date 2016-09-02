require 'bundler/setup'
require 'pry'
require 'pry-doc'
require 'active_record'
require 'database_rewinder'
require 'i18n'

Bundler.require

require "#{File.dirname(__FILE__)}/support/setup_database.rb"
require "#{File.dirname(__FILE__)}/support/model.rb"

RSpec.configure do |config|
  I18n.backend = I18n::Backend::Simple.new
  I18n.backend.load_translations(Dir.glob("#{File.dirname(__FILE__)}/support/locales/*.yml"))

  Time::DATE_FORMATS[:ymdhms] = '%Y/%m/%d %H:%M:%S'

  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end
end
