module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Mapped < ::ActiveRecord::Bixformer::Model::Csv::Base
          def initialize(model_or_association_name, options)
            super

            unless options[:key] || options[:in]
              raise ArgumentError.new 'Not configure required options : key, in'
            end
          end

          def export(record_or_relation)
            # has_many でしか使わない想定なので record_or_relation は ActiveRecord::Relation のはず
            record_of = record_or_relation&.where(@options[:key] => @options[:in])&.index_by(@options[:key]) || {}

            errors.clear

            run_bixformer_callback :export do
              @options[:in].inject({}) do |values, key|
                update_translator(key)

                values.merge(do_export(record_of[key]))
              end
            end
          end

          def import(csv_body_row, parent_record_id = nil)
            errors.clear

            run_bixformer_callback :import do
              @options[:in].map do |key|
                update_translator(key)

                do_import(csv_body_row, parent_record_id)
              end
            end
          end

          def verify_csv_titles(csv_title_row)
            @options[:in].map do |key|
              update_translator(key)

              return false unless super
            end
          end

          def translate(attribute_name)
            # TODO: mapped 以外の複数を扱うクラスがあった時の対処が必要
            if parents.find { |parent| parent.is_a?(::ActiveRecord::Bixformer::Model::Csv::Mapped) }
              parents.map { |parent| parent.translator.translate_model }.join + super
            else
              super
            end
          end

          private

          def sortable_csv_titles
            @options[:in].flat_map do |key|
              update_translator(key)

              super
            end
          end

          def update_translator(key)
            key = @options[:translate] ? @options[:translate].call(key) : key

            @translator.model_arguments = { key: key }

            @translator.attribute_arguments_map = @attributes.map do |attr|
              [attr.name, { key: key }]
            end.to_h
          end
        end
      end
    end
  end
end
