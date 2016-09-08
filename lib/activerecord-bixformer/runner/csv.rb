require 'csv'

module ActiveRecord
  module Bixformer
    module Runner
      class Csv < ::ActiveRecord::Bixformer::Runner::Base
        def initialize
          super(:csv)
        end

        def import(csv_data, csv_parse_options = {})
          modeler = detect_modeler
          @errors = []

          csv_parse_options[:headers] = true

          model_attributes_list = ::CSV.parse(csv_data, csv_parse_options).map do |csv_row|
            modeler.new_module_instance(:generator, :active_record, modeler, csv_row).generate
          end

          model_constant = modeler.model_name.to_s.camelize.constantize

          model_constant.transaction do
            model_attributes_list.each.with_index(1) do |model_attributes, index|
              import_attributes(model_constant, model_attributes, index)
            end

            raise ::ActiveRecord::Rollback unless @errors.empty?
          end

          @errors.empty?
        end

        def export(active_records_or_relation, csv_generate_options = {})
          modeler    = detect_modeler
          csv_titles = make_csv_titles(modeler, active_records_or_relation)

          ::CSV.generate(csv_generate_options) do |csv|
            csv << csv_titles

            active_records_or_relation.each do |activerecord|
              generator = modeler.new_module_instance(:generator, :csv_row, modeler, activerecord)

              csv << export_attributes(csv_titles, generator.generate)
            end
          end
        end

        private

        def make_csv_titles(modeler, active_records_or_relation)
          generator = modeler.new_module_instance(:generator, :csv_row, modeler, active_records_or_relation.first)

          generator.compile.available_csv_titles
        end

        def import_attributes(model_constant, model_attributes, index)
          identified_value = model_attributes[model_constant.primary_key]

          # CSVで削除が可能だが、削除フラグは _destroy というattributesに入っており、こんなcolumnは存在しないので、このままだとエラーになる
          # そのため、ここで要素から削除しておく
          is_destroy = model_attributes.delete(:_destroy)

          activerecord = if identified_value
                           model_constant.find(identified_value)
                         else
                           model_constant.new(model_attributes)
                         end

          success = if identified_value
                      if is_destroy
                        activerecord.destroy
                      else
                        activerecord.update(model_attributes)
                      end
                    else
                      activerecord.save
                    end

          @errors += make_error_messages(activerecord, index) unless success
        end

        def export_attributes(csv_titles, model_attributes)
          csv_titles.map { |title| model_attributes[title] }
        end

        def make_error_messages(activerecord, index)
          activerecord.errors.full_messages.map do |msg|
            "Entry#{index}: #{msg}"
          end
        end
      end
    end
  end
end
