require 'csv'

module ActiveRecord
  module Bixformer
    module Runner
      class Csv < ::ActiveRecord::Bixformer::Runner::Base
        def initialize
          super(:csv)
        end

        def import(csv_data, options = {})
          modeler        = active_modeler(true)
          model_constant = modeler.model_name.to_s.camelize.constantize

          @errors           = []
          options[:headers] = true

          model_attributes_list = parse_csv_rows(::CSV.parse(csv_data, options))

          model_constant.transaction do
            model_attributes_list.each.with_index(1) do |model_attributes, index|
              next unless model_attributes&.present?

              identified_value = model_attributes[model_constant.primary_key]

              activerecord = if identified_value
                               find_activerecord(model_constant, identified_value)
                             else
                               build_activerecord(model_constant, model_attributes)
                             end

              unless save_activerecord(activerecord, model_attributes)
                @errors += make_error_messages(activerecord, index)
              end
            end

            raise ::ActiveRecord::Rollback unless @errors.empty?
          end

          @errors.empty?
        end

        def export(active_records_or_relation, options = {})
          modeler    = active_modeler(true)
          generator  = modeler.new_module_instance(:generator, :csv_row, modeler, active_records_or_relation.first)
          csv_titles = make_csv_titles(generator)

          ::CSV.generate(options) do |csv|
            csv << csv_titles

            active_records_or_relation.each do |activerecord|
              generator = modeler.new_module_instance(:generator, :csv_row, modeler, activerecord)

              csv << make_csv_row(generator, csv_titles)
            end
          end
        end

        private

        def make_csv_titles(generator)
          generator.compile.available_csv_titles
        end

        def make_csv_row(generator, csv_titles)
          model_attributes = generator.generate

          csv_titles.map { |title| model_attributes[title] }
        end

        def parse_csv_rows(csv_rows)
          modeler = active_modeler

          csv_rows.map do |csv_row|
            generator = modeler.new_module_instance(:generator, :active_record, modeler, csv_row)

            parse_csv_row(generator)
          end
        end

        def parse_csv_row(generator)
          generator.generate
        end

        def find_activerecord(model_class, id)
          model_class.find(id)
        end

        def build_activerecord(model_class, attributes)
          model_class.new(attributes)
        end

        def save_activerecord(activerecord, assigned_attributes)
          # CSVで削除が可能だが、削除フラグは _destroy というattributesに入っており、こんなcolumnは存在しないので、このままだとエラーになる
          # そのため、ここで要素から削除しておく
          is_destroy = assigned_attributes.delete(:_destroy)

          if activerecord.persisted?
            if is_destroy
              activerecord.destroy
            else
              activerecord.update(assigned_attributes)
            end
          else
            activerecord.save
          end
        end

        def make_error_messages(activerecord, csv_row_index)
          activerecord.errors.full_messages.map do |msg|
            I18n.t(
              :"bixformer.csv.errors.format", {
                default: "Entry(%{csv_row_index}): %{message}",
                csv_row_index: csv_row_index,
                message: msg
              }
            )
          end
        end
      end
    end
  end
end
