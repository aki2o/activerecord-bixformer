module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Indexed < ::ActiveRecord::Bixformer::Model::Csv::Base
          def initialize(model_or_association_name, options)
            super

            @options[:size] ||= 1
          end

          def export(record_or_records)
            record_or_records ||= []

            # has_many でしか使わない想定なので record_or_records は Array のはず
            (1..options[:size]).inject({}) do |values, index|
              update_translator(index)

              values.merge(super(record_or_records[index-1]))
            end
          end

          def import(csv_row, parent_record_id = nil)
            # has_many でしか使わない想定なので Array を返却
            (1..options[:size]).map do |index|
              update_translator(index)

              super
            end
          end

          def csv_titles
            (1..options[:size]).flat_map do |index|
              update_translator(index)

              super
            end
          end

          def csv_title(attribute_name)
            if parents.find { |parent| parent.is_a?(::ActiveRecord::Bixformer::Model::Csv::Indexed) }
              parents.map { |parent| parent.translator.translate_model }.join + super
            else
              super
            end
          end

          private

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
