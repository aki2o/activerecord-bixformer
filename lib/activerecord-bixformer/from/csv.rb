module ActiveRecord
  module Bixformer
    module From
      class Csv < ::ActiveRecord::Bixformer::Compiler
        def initialize(plan)
          super(:csv, plan)
        end

        def assignable_attributes(csv_row)
          compile.make_import_value(csv_row)
        end
      end
    end
  end
end
