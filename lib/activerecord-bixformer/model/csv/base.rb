module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Base < ::ActiveRecord::Bixformer::Model::Base
          def export(record_or_records)
            run_bixformer_callback :export do
              values = run_bixformer_callback :export, type: :attribute do
                # has_one でしか使わない想定なので record_or_records は ActiveRecord::Base のはず
                @attributes.map do |attr|
                  attribute_value = if record_or_records
                                      run_bixformer_callback :export, on: attr.name do
                                        attr.export(record_or_records)
                                      end
                                    end

                  [csv_title(attr.name), attribute_value]
                end.to_h.with_indifferent_access
              end

              run_bixformer_callback :export, type: :association do
                @associations.inject(values) do |each_values, association|
                  association_value = if record_or_records
                                        run_bixformer_callback :export, on: association.name do
                                          record_or_records.__send__(association.name)
                                        end
                                      end

                  association_value = association_value.to_a if association_value.is_a?(::ActiveRecord::Relation)

                  each_values.merge(association.export(association_value))
                end
              end
            end
          end

          def import(csv_body_row, parent_record_id = nil)
            run_bixformer_callback :import do
              values = make_each_attribute_import_value(parent_record_id) do |attr|
                csv_value = csv_body_row[csv_title(attr.name)]

                attr.import(csv_value)
              end

              make_each_association_import_value(values) do |association, self_record_id|
                association.import(csv_body_row, self_record_id)
              end
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
