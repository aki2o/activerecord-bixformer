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
          required_attributes    = @modeler.config_value_for(model, :required_attributes, [])
          identified_column_name = identified_column_name_of(model)

          # 必須な属性が渡されていない場合には、取り込みしない
          return {} if required_attributes.any? { |attribute_name| ! presence_value?(attribute_value_map[attribute_name]) }

          set_parent_key(model, attribute_value_map, identified_column_name)
          set_activerecord_id(model, attribute_value_map, identified_column_name)

          # 空でない要素が無いなら、空ハッシュで返す
          presence_value?(attribute_value_map) ? attribute_value_map : {}
        end

        def generate_association_value(parent_model)
          association_value_map = {}.with_indifferent_access

          parent_model.association_map.each do |association_name, model_or_models|
            association_value = if model_or_models.is_a?(::Array)
                                  model_or_models.map { |m| generate_model_value(m) }.reject { |v| ! presence_value?(v) }
                                else
                                  generate_model_value(model_or_models)
                                end

            # 取り込み時は、オプショナルな関連では、空と思われる値は取り込まない
            next if ! presence_value?(association_value) &&
                    parent_model.optional_attributes.include?(association_name.to_s)

            association_value_map["#{association_name}_attributes".to_sym] = association_value
          end

          association_value_map
        end

        def set_parent_key(model, attribute_value_map, identified_column_name)
          # 結果ハッシュが空なら、取り込みしないように追加はしない
          return unless presence_value?(attribute_value_map)

          # 誤って関連レコードが変わってしまうことを避けるために、
          # id属性が指定されている場合には、処理しない
          return if attribute_value_map[identified_column_name]

          # 親のレコードが見つかっているなら、それも結果ハッシュに追加する
          parent_id = model.parent&.activerecord_id

          return unless parent_id

          attribute_value_map[model.parent_foreign_key] = parent_id
        end

        def set_activerecord_id(model, attribute_value_map, identified_column_name)
          # id属性が既に結果ハッシュにあれば、それを使い、なければ、DBから検索を試みて、
          # その結果を、結果ハッシュにも代入
          model.activerecord_id = attribute_value_map[identified_column_name] ||=
                                  find_activerecord_id(model, attribute_value_map, identified_column_name)
        end

        def find_activerecord_id(model, attribute_value_map, identified_column_name)
          unique_indexes = @modeler.config_value_for(model, :unique_indexes, [])

          # ユニーク条件が指定されていないなら終了
          return nil if unique_indexes.empty?

          unique_conditions = unique_indexes.map do |key|
            [key, attribute_value_map[key]]
          end.to_h

          # ユニーク条件は、必ず値がなければならない
          return nil if unique_conditions.any? { |_k, v| ! presence_value?(v) }

          # 指定された条件でレコードを検索し、id を格納しているカラムがあるかチェックする
          activerecord = model.activerecord_constant.find_by(unique_conditions)

          return nil unless activerecord&.respond_to?(identified_column_name)

          activerecord.__send__(identified_column_name)
        end

        def identified_column_name_of(model)
          model.activerecord_constant.primary_key
        end

        def presence_value?(value)
          # 空でない要素であるか or 空でない要素を含んでいるかどうか
          case value
          when ::Hash
            value.values.any? { |v| presence_value?(v) }
          when ::Array
            value.any? { |v| presence_value?(v) }
          when ::String
            ! value.blank?
          when ::TrueClass, ::FalseClass
            true
          else
            value ? true : false
          end
        end
      end
    end
  end
end
