module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Indexed < ::ActiveRecord::Bixformer::Model::Csv::Base
          def initialize(model_or_association_name, options)
            super

            @options[:size] ||= 1
          end

          def export(record_or_relation)
            record_or_relation ||= []

            errors.clear

            run_bixformer_callback :export do
              # has_many でしか使わない想定なので record_or_relation は ActiveRecord::Relation のはず
              (1..options[:size]).inject({}) do |values, index|
                update_translator(index)

                values.merge(do_export(record_or_relation[index-1]))
              end
            end
          end

          def import(csv_body_row, parent_record_id = nil)
            errors.clear

            run_bixformer_callback :import do
              # has_many でしか使わない想定なので ActiveRecord::Relation を返却
              (1..options[:size]).map do |index|
                update_translator(index)

                do_import(csv_body_row, parent_record_id)
              end
            end
          end

          def verify_csv_titles(csv_title_row)
            # size は可変長なので、'1'だけ検証する
            update_translator(1)

            super
          end

          def csv_title(attribute_name)
            # TODO: indexed 以外の複数を扱うクラスがあった時の対処が必要
            if parents.find { |parent| parent.is_a?(::ActiveRecord::Bixformer::Model::Csv::Indexed) }
              parents.map { |parent| parent.translator.translate_model }.join + super
            else
              super
            end
          end

          private

          def sortable_csv_titles
            (1..options[:size]).flat_map do |index|
              update_translator(index)

              super
            end
          end

          def update_translator(index)
            @translator.model_arguments = { index: index }

            @translator.attribute_arguments_map = @attributes.map do |attr|
              [attr.name, { index: index }]
            end.to_h
          end
        end
      end
    end
  end
end
