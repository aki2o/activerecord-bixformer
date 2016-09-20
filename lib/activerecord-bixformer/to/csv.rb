module ActiveRecord
  module Bixformer
    module To
      class Csv < ::ActiveRecord::Bixformer::Compiler
        def initialize(plan)
          super(:csv, plan)
        end

        def csv_title_row
          compile.csv_titles
        end

        def csv_body_row(activerecord)
          model    = compile
          body_map = model.export(activerecord)

          model.csv_titles.map { |title| body_map[title] }
        end
      end
    end
  end
end
