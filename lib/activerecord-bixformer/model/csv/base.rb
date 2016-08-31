module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Base < ::ActiveRecord::Bixformer::Model::Base
          class << self
            def new_as_association_for_import(parent, association_name, options)
              model = self.class.new(association_name, options)

              model.data_source = parent.data_source # parent.data_source is CSV::Row

              model
            end
          end

          def setup_with_modeler(modeler)
            super

            # CSVカラム名の取得にはI18nを使う
            @translator = ::ActiveRecord::Bixformer::Translator::I18n.new

            @translator.settings = @modeler.translation_settings.dup
            @translator.model    = self
          end

          def csv_title(attribute_name)
            @translator.translate_attribute(attribute_name)
          end

          def available_csv_titles
            [
              *@attribute_map.keys.map do |attribute_name|
                csv_title(attribute_name)
              end,
              *@association_map.values.flat_map do |model_or_models|
                models = model_or_models.is_a?(::Array) ? model_or_models : [model_or_models]

                models.flat_map { |m| m.available_csv_titles }
              end
            ]
          end

          private

          def make_import_value(attribute_name)
            return nil unless @data_source

            attribute                   = @attribute_map[attribute_name]
            data_source_attribute_value = @data_source[csv_title(attribute_name)]

            attribute.make_import_value(data_source_attribute_value)
          end
        end
      end
    end
  end
end
