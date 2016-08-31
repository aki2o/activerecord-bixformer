module ActiveRecord
  module Bixformer
    module Generator
      class ActiveRecord < ::ActiveRecord::Bixformer::Generator::Base
        private

        def association_generator
          :new_as_association_for_import
        end

        def generate_model_value(model)
          generate_attributes_value(model).merge(generate_association_value(model))
        end

        def generate_attributes_value(model)
          attribute_value_map    = model.generate_import_value_map
          identified_column_name = identified_column_name_of(model)

          model.activerecord_id = find_activerecord_id(model, attribute_value_map)

          if attribute_value_map.key?(identified_column_name) || model.activerecord_id
            # 結果ハッシュにid属性のキーがあるか、対象レコードのidが見つかった場合は
            # 結果ハッシュのid属性をDB検索結果で更新
            attribute_value_map[identified_column_name] = model.activerecord_id
          end

          attribute_value_map
        end

        def generate_association_value(parent_model)
          association_value_map = {}

          parent_model.association_map.each do |association_name, model_or_models|
            association_value = if model_or_models.is_a?(::Array)
                                  model_or_models.map { |m| generate_model_value(m) }.reject { |v| has_valid_value?(v) }
                                else
                                  generate_model_value(model_or_models)
                                end

            # 取り込み時は、オプショナルな関連では、空と思われる値は取り込まない
            next if has_valid_value?(association_value) &&
                    parent_model.optional_attributes.include?(association_name)

            association_value_map["#{association_name}_attributes"] = association_value
          end

          association_value_map
        end

        def find_activerecord_id(model, attribute_value_map)
          primary_keys = @modeler.config_value_for(model, :primary_keys, [:id])

          return nil if primary_keys.empty?

          primary_conditions = primary_keys.map do |pkey|
            [pkey, attribute_value_map[pkey]]
          end.to_h

          # primay key 条件は、必ず値がなければならない
          return nil if primary_conditions.find { |_k, v| v.blank? }

          # 親のレコードが見つかっているなら、それも primary key に追加する
          parent_id = model.parent&.activerecord_id

          primary_conditions[model.parent_foreign_key] = parent_id if parent_id

          # 指定された条件でレコードを検索し、id を格納しているカラムがあるかチェックする
          activerecord           = model.activerecord_constant.find_by(primary_conditions)
          identified_column_name = identified_column_name_of(model)

          return nil unless activerecord&.respond_to?(identified_column_name)

          activerecord.__send__(identified_column_name)
        end

        def identified_column_name_of(model)
          @modeler.config_value_for(model, :entry_definitions, {})[:identified_by] || :id
        end

        def has_valid_value?(array_or_hash)
          if array_or_hash.is_a?(::Hash)
            ! array_or_hash.values.empty?
          elsif array_or_hash.is_a?(::Array)
            ! array_or_hash.empty?
          end
        end
      end
    end
  end
end
