require 'activerecord-bixformer/version'

module ActiveRecord
  module Bixformer
    module Attribute
      autoload :Base,       'activerecord-bixformer/attribute/base'
      autoload :Boolean,    'activerecord-bixformer/attribute/boolean'
      autoload :Booletania, 'activerecord-bixformer/attribute/booletania'
      autoload :Date,       'activerecord-bixformer/attribute/date'
      autoload :Enumerize,  'activerecord-bixformer/attribute/enumerize'
      autoload :Override,   'activerecord-bixformer/attribute/override'
      autoload :Time,       'activerecord-bixformer/attribute/time'
    end

    module Generator
      autoload :ActiveRecord, 'activerecord-bixformer/generator/active_record'
      autoload :Base,         'activerecord-bixformer/generator/base'
      autoload :CsvRow,       'activerecord-bixformer/generator/csv_row'
    end

    module Model
      autoload :Base, 'activerecord-bixformer/model/base'

      module Csv
        autoload :Base,    'activerecord-bixformer/model/csv/base'
        autoload :Indexed, 'activerecord-bixformer/model/csv/indexed'
      end
    end

    module Modeler
      autoload :Base, 'activerecord-bixformer/modeler/base'
      autoload :Csv, 'activerecord-bixformer/modeler/csv'
    end

    module Runner
      autoload :Base, 'activerecord-bixformer/runner/base'
      autoload :Csv, 'activerecord-bixformer/runner/csv'
    end

    module Translator
      autoload :I18n, 'activerecord-bixformer/translator/i18n'
    end
  end
end
