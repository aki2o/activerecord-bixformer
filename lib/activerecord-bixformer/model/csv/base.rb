module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Base < ::ActiveRecord::Bixformer::Model::Base
          def import(csv_row, parent_activerecord_id = nil)
            values = make_each_attribute_import_value(parent_activerecord_id) do |attr|
              csv_value = csv_row[csv_title(attr.name)]

              attr.import(csv_value)
            end

            make_each_association_import_value(values) do |association, self_activerecord_id|
              association.import(csv_row, self_activerecord_id)
            end
          end

          def csv_titles
            [
              *@attributes.map { |attr| csv_title(attr.name) },
              *@associations.flat_map(&:csv_titles)
            ]
          end

          def csv_title(attribute_name)
            @translator.translate_attribute(attribute_name)
          end
        end
      end
    end
  end
end
