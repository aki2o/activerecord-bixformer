module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Base < ::ActiveRecord::Bixformer::Model::Base
          def export(record_or_records)
            # has_one でしか使わない想定なので record_or_records は ActiveRecord::Base のはず
            values = @attributes.map do |attr|
              attribute_value = record_or_records && attr.export(record_or_records)

              [csv_title(attr.name), attribute_value]
            end.to_h.with_indifferent_access

            @associations.inject(values) do |each_values, association|
              association_value = record_or_records && record_or_records.__send__(association.name)

              association_value = association_value.to_a if association_value.is_a?(::ActiveRecord::Relation)

              each_values.merge(association.export(association_value))
            end
          end

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
