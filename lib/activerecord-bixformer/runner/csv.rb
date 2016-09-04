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
          @errors  = []

          csv_parse_options[:headers] = true

          model_attributes_list = ::CSV.parse(csv_data, csv_parse_options).map do |csv_row|
            modeler.new_module_instance(:generator, :active_record, modeler, csv_row).generate
          end

          model_constant = modeler.model_name.to_s.camelize.constantize

          model_constant.transaction do
            model_attributes_list.each.with_index(1) do |model_attributes, index|
              begin
                import_attributes(model_constant, model_attributes)
              rescue => e
                @errors << make_error_message(e, index)
              end
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

        def import_attributes(model_constant, model_attributes)
          identified_value = model_attributes[model_constant.primary_key]

          if identified_value
            model_constant.find(identified_value).update!(model_attributes)
          else
            model_constant.new(model_attributes).save!
          end
        end

        def export_attributes(csv_titles, model_attributes)
          csv_titles.map { |title| model_attributes[title] }
        end

        def make_error_message(e, index)
          case e
          when ::ActiveRecord::RecordInvalid
            e.errors.full_messages.join(', ')
          when ::ActiveRecord::RecordNotFound
            e.message
          else
            e.message
          end
        end
      end
    end
  end
end
