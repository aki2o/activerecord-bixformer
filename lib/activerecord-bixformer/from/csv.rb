module ActiveRecord
  module Bixformer
    module From
      class Csv < ::ActiveRecord::Bixformer::Compiler
        def initialize(plan)
          super(:csv, plan)
        end

        def verify_csv_titles(csv_title_row)
          compile.verify_csv_titles(csv_title_row)
        end

        def assignable_attributes(csv_body_row)
          compile.import(csv_body_row)
        end
      end
    end
  end
end
