module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Base < ::ActiveRecord::Bixformer::Model::Base
          def export(record_or_relation)
            errors.clear

            run_bixformer_callback :export do
              do_export(record_or_relation)
            end
          end

          def import(csv_body_row, parent_record_id = nil)
            errors.clear

            run_bixformer_callback :import do
              do_import(csv_body_row, parent_record_id)
            end
          end

          def verify_csv_titles(csv_title_row)
            attribute_names = activerecord_constant.attribute_names

            @attributes
              .select { |attr| attribute_names.include?(attr.name) }
              .map { |attr| csv_title(attr.name) }
              .all? { |title| csv_title_row.include?(title) } &&
              @associations.all? { |ass| ass.verify_csv_titles(csv_title_row) }
          end

          def csv_titles
            sort(sortable_csv_titles)
          end

          def csv_title(attribute_name)
            @translator.translate_attribute(attribute_name)
          end

          alias_method :translate, :csv_title

          private

          def do_export(record_or_relation)
            values = run_bixformer_callback :export, type: :attribute do
              # has_one でしか使わない想定なので record_or_relation は ActiveRecord::Base のはず
              @attributes.map do |attr|
                attribute_value = if record_or_relation
                                    run_bixformer_callback :export, on: attr.name do
                                      attr.export(record_or_relation)
                                    end
                                  end

                [csv_title(attr.name), attribute_value]
              end.to_h.with_indifferent_access
            end

            run_bixformer_callback :export, type: :association do
              @associations.inject(values) do |each_values, association|
                association_value =
                  if record_or_relation
                    run_bixformer_callback :export, on: association.name do
                      association_record_or_relation = record_or_relation.__send__(association.name)

                      if association_record_or_relation.is_a?(::ActiveRecord::Relation)
                        association_record_or_relation =
                          association_record_or_relation.where(@plan.pickup_value_for(association, :required_condition, {}))
                      end

                      association.export(association_record_or_relation)
                    end
                  end

                each_values.merge(association_value || {})
              end
            end
          end

          def do_import(csv_body_row, parent_record_id = nil, initializer: {})
            values = make_each_attribute_import_value(parent_record_id, initializer: initializer) do |attr|
              attr.import(csv_body_row[csv_title(attr.name)])
            end

            make_each_association_import_value(values) do |association, self_record_id|
              association.import(csv_body_row, self_record_id)
            end
          end

          def sortable_csv_titles
            [
              *@attributes.map { |attr| sortable_value(attr, csv_title(attr.name)) },
              *@associations.flat_map { |assoc| assoc.__send__(:sortable_csv_titles) }
            ]
          end
        end
      end
    end
  end
end
