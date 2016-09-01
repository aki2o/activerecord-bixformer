require 'bundler/setup'
require 'pry'
require 'pry-doc'
require 'i18n'

Bundler.require

require "#{File.dirname(__FILE__)}/support/setup_database.rb"
require "#{File.dirname(__FILE__)}/support/model.rb"

RSpec.configure do
  I18n.backend = I18n::Backend::Simple.new
  I18n.backend.load_translations(Dir.glob("#{File.dirname(__FILE__)}/support/locales/*.yml"))

  Time::DATE_FORMATS[:ymdhms] = '%Y/%m/%d %H:%M:%S'
end
