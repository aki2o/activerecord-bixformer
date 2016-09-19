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

        # private

        # def csv_body_map_by_model(model, activerecord_or_activerecords)
        #   activerecord_or_activerecords = if activerecord_or_activerecords.is_a?(::ActiveRecord::Relation)
        #                                     activerecord_or_activerecords.to_a
        #                                   else
        #                                     activerecord_or_activerecords
        #                                   end

        #   model.generate_export_value(activerecord_or_activerecords).merge(
        #     csv_body_map_by_association(model, activerecord_or_activerecords)
        #   )
        # end

        # def csv_body_map_by_association(model, activerecord_or_activerecords)
        #   model.associations.inject({}) do |body_map, association_model|
        #     activerecords = if activerecord_or_activerecords.is_a?(::Array)
        #                       activerecord_or_activerecords
        #                     else
        #                       [activerecord_or_activerecords]
        #                     end

        #     body_map.merge(
        #       activerecords.inject({}) do |body_each_map, activerecord|
        #         association_value = activerecord.__send__(association_model.name)

        #         body_each_map.merge(
        #           csv_body_map_by_model(association_model, association_value)
        #         )
        #       end
        #     )
        #   end
        # end
      end
    end
  end
end
