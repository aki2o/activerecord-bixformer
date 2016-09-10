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

          # 親のレコードが見つかっているなら、それも結果ハッシュに追加する
          parent_id = model.parent&.activerecord_id

          return unless parent_id

          attribute_value_map[model.parent_foreign_key] = parent_id
        end

        def set_activerecord_id(model, attribute_value_map, identified_column_name)
          # 更新の場合は、インポートデータを元にデータベースから対象のレコードを検索してIDを取得
          model.activerecord_id = verified_activerecord_id(model, attribute_value_map, identified_column_name)

          if model.activerecord_id
            # 更新なら、ID属性を改めて設定
            attribute_value_map[identified_column_name] = model.activerecord_id
          else
            # 追加なら、ID属性があるとダメなのでキー自体を削除
            attribute_value_map.delete(identified_column_name)
          end
        end

        def verified_activerecord_id(model, attribute_value_map, identified_column_name)
          # 更新対象のレコードを特定できるかチェック
          identified_value = attribute_value_map[identified_column_name]

          uniqueness_condition = if identified_value
                                   { identified_column_name => identified_value }
                                 else
                                   find_unique_condition(model, attribute_value_map, identified_column_name)
                                 end

          # レコードが特定できないなら、更新処理ではないので終了
          return nil unless uniqueness_condition

          # 更新対象のレコードを正しく特定できているか確認するための検証条件を取得
          required_condition = if model.parent
                                 key = model.parent_foreign_key

                                 { key => attribute_value_map[key] }
                               else
                                 @modeler.required_condition
                               end

          # 検証条件は、必ず値がなければならない
          return nil if required_condition.any? { |_k, v| ! presence_value?(v) }

          # インポートされてきた、レコードを特定する条件が、誤った値でないかどうかを、
          # 特定されるレコードが、更新すべき正しいレコードであるかチェックするための
          # 検証条件とマージして、データベースに登録されているか確認する
          verified_condition = uniqueness_condition.merge(required_condition)

          model.activerecord_constant.find_by!(verified_condition).__send__(identified_column_name)
        rescue ::ActiveRecord::RecordNotFound => e
          # ID属性が指定されているのに、データベースに見つからない場合はエラーにする
          raise e if identified_value
        end

        def find_unique_condition(model, attribute_value_map, identified_column_name)
          unique_indexes = @modeler.config_value_for(model, :unique_indexes, [])

          # ユニーク条件が指定されていないなら終了
          return nil if unique_indexes.empty?

          unique_condition = unique_indexes.map do |key|
            [key, attribute_value_map[key]]
          end.to_h

          # ユニーク条件は、必ず値がなければならない
          return nil if unique_condition.any? { |_k, v| ! presence_value?(v) }

          unique_condition
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
