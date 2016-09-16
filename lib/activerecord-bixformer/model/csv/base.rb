module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Base < ::ActiveRecord::Bixformer::Model::Base
          def make_export_value(activerecord_or_activerecords)
            # has_one でしか使わない想定なので activerecord_or_activerecords は ActiveRecord::Base のはず
            values = @attributes.map do |attr|
              attribute_value = activerecord_or_activerecords && activerecord_or_activerecords.__send__(attr.name)

              [csv_title(attr.name), attr.make_export_value(attribute_value)]
            end.to_h.with_indifferent_access

            @associations.inject(values) do |each_values, association|
              association_value = activerecord_or_activerecords && activerecord_or_activerecords.__send__(association.name)

              association_value = association_value.to_a if association_value.is_a?(::ActiveRecord::Relation)

              each_values.merge(association.make_export_value(association_value))
            end
          end

          def make_import_value(csv_row, parent_activerecord_id = nil)
            values = make_each_attribute_import_value(parent_activerecord_id) do |attr|
              csv_value = csv_row[csv_title(attr.name)]

              attr.make_import_value(csv_value)
            end

            make_each_association_import_value(values) do |association, self_activerecord_id|
              association.make_import_value(csv_row, self_activerecord_id)
            end
          end

          def csv_titles
            [
              *@attributes.map { |attr| csv_title(attr.name) },
              *@associations.flat_map(&:csv_titles)
            ]
          end

          def parse_self_data_source(csv_row)
            csv_row
          end

          private

          def csv_title(attribute_name)
            @translator.translate_attribute(attribute_name)
          end
        end
      end
    end
  end
end
