require 'bundler/setup'
require 'pry'
require 'pry-doc'
require 'active_record'
require 'database_rewinder'
require 'i18n'

Bundler.require

require "#{File.dirname(__FILE__)}/support/setup_database.rb"
require "#{File.dirname(__FILE__)}/support/model.rb"
Dir["#{File.dirname(__FILE__)}/support/samples/*.rb"].each { |f| require f }

RSpec.configure do |config|
  I18n.backend = I18n::Backend::Simple.new
  I18n.backend.load_translations(Dir.glob("#{File.dirname(__FILE__)}/support/locales/*.yml"))
  I18n.available_locales = [:en, :ja]
  I18n.enforce_available_locales = true
  I18n.default_locale = :en

  Date::DATE_FORMATS[:ymd]    = '%Y %m %d'
  Time::DATE_FORMATS[:ymdhms] = '%Y %m %d (%H:%M:%S)'

  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end
end
