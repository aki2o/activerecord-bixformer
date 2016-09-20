module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Base < ::ActiveRecord::Bixformer::Model::Base
          def import(csv_body_row, parent_record_id = nil)
            values = make_each_attribute_import_value(parent_record_id) do |attr|
              csv_value = csv_body_row[csv_title(attr.name)]

              attr.import(csv_value)
            end

            make_each_association_import_value(values) do |association, self_record_id|
              association.import(csv_body_row, self_record_id)
            end
          end

          def verify_csv_titles(csv_title_row)
            @attributes.map { |attr| csv_title(attr.name) }.all? { |title| csv_title_row.include?(title) } &&
              @associations.all? { |ass| ass.verify_csv_titles(csv_title_row) }
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
