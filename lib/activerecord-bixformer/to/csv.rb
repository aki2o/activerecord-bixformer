module ActiveRecord
  module Bixformer
    module To
      class Csv < ::ActiveRecord::Bixformer::Compiler
        def initialize(plan)
          super(:csv, plan)
        end

        def clear
          super

          @csv_title_row = nil
        end

        def csv_title_row
          @csv_title_row ||= compile.csv_titles
        end

        def csv_body_row(activerecord)
          body_map = compile.export(activerecord)

          csv_title_row.map { |title| body_map[title] }
        end
      end
    end
  end
end
