require 'activerecord-bixformer/autoload'

module ActiveRecord
  module Bixformer
    module Model
      module Csv
        autoload :Base,    'activerecord-bixformer/model/csv/base'
        autoload :Indexed, 'activerecord-bixformer/model/csv/indexed'
        autoload :Mapped,  'activerecord-bixformer/model/csv/mapped'
      end
    end

    module From
      autoload :Csv, 'activerecord-bixformer/from/csv'
    end

    module To
      autoload :Csv, 'activerecord-bixformer/to/csv'
    end
  end
end
