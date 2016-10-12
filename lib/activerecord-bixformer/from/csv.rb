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
          model = compile

          result = model.import(csv_body_row)

          raise ::ActiveRecord::Bixformer::ImportError.new(model) if model.errors.present?

          result
        end
      end
    end
  end
end
