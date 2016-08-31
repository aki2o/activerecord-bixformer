module ActiveRecord
  module Bixformer
    module Generator
      class CsvRow < ActiveRecord::Bixformer::Generator::Base
        private

        def association_generator
          :new_as_association_for_export
        end

        def generate_model_value(model)
          model.generate_export_value_map

          generate_attributes_value(model).merge(generate_association_value(model))
        end

        def generate_attributes_value(model)
          model.generate_export_value_map.map do |attribute_name, attribute_value|
            [model.csv_title(attribute_name), attribute_value]
          end.to_h
        end

        def generate_association_value(parent_model)
          parent_model.association_map.values.inject({}) do |association_value, model_or_models|
            models = model_or_models.is_a?(Array) ? model_or_models : [model_or_models]

            # 全関連レコードの生成結果を単一ハッシュにマージ
            association_value.merge(
              models.inject({}) do |current_association_value, model|
                # 関連レコードの全生成結果を単一ハッシュにマージ
                current_association_value.merge(
                  # キーをCSVカラム名に置き換えたハッシュを作成
                  generate_model_value(model)
                )
              end
            )
          end
        end
      end
    end
  end
end
