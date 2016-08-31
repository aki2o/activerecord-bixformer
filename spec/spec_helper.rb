require 'bundler/setup'
require 'pry'
require 'pry-doc'
require 'i18n'

Bundler.require
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do
  I18n.backend = I18n::Backend::Simple.new
  I18n.backend.load_translations(Dir.glob("#{File.dirname(__FILE__)}/support/locales/*.yml"))
end
