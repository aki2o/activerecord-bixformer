module ActiveRecord
  module Bixformer
    class AssignableAttributesNormalizer
      include ::ActiveRecord::Bixformer::ImportValueValidatable

      def initialize(plan, model, parent_activerecord_id)
        @plan                   = ActiveRecord::Bixformer::PlanAccessor.new(plan)
        @model                  = model
        @parent_activerecord_id = parent_activerecord_id
        @identified_column_name = @model.activerecord_constant.primary_key
      end

      def normalize(model_attributes)
        @model_attributes = model_attributes

        return {} unless @model_attributes

        # 必須な属性が渡されていない場合には、取り込みしない
        return {} unless validate_required_attributes

        set_required_condition   if presence_value?(@model_attributes)
        set_parent_foreign_key   if presence_value?(@model_attributes)
        set_identified_attribute if presence_value?(@model_attributes)

        # 空でない要素が無いなら、空ハッシュで返す
        return {} unless presence_value?(@model_attributes)

        @model_attributes
      end

      private

      def validate_required_attributes
        required_attributes = @plan.pickup_value_for(@model, :required_attributes, [])

        required_attributes.all? { |attribute_name| presence_value?(@model_attributes[attribute_name]) }
      end

      def set_required_condition
        # 設定するのはルートの場合のみ
        return if @model.parent

        @model_attributes.merge!(@plan.value_of(:required_condition))
      end

      def set_parent_foreign_key
        # 設定するのは親がいる場合のみ
        return unless @model.parent

        if @parent_activerecord_id
          # 親のレコードが見つかっているなら、それも結果ハッシュに追加する
          @model_attributes[@model.parent_foreign_key] = @parent_activerecord_id
        else
          # 見つかっていないなら、間違った値が指定されている可能性があるので、キー自体を削除
          @model_attributes.delete(@model.parent_foreign_key)
        end
      end

      def set_identified_attribute
        # 更新の場合は、インポートデータを元にデータベースから対象のレコードを検索してIDを取得
        verified_id = verified_activerecord_id

        if verified_id
          # 更新なら、ID属性を改めて設定
          @model_attributes[@identified_column_name] = verified_id
        else
          # 見つかっていないなら、間違った値が指定されている可能性があるので、キー自体を削除
          @model_attributes.delete(@identified_column_name)
        end
      end

      def verified_activerecord_id
        # 更新対象のレコードを特定できるかチェック
        identified_value = @model_attributes[@identified_column_name]

        uniqueness_condition = if identified_value
                                 { @identified_column_name => identified_value }
                               else
                                 find_unique_condition
                               end

        # レコードが特定できないなら、更新処理ではないので終了
        return nil unless uniqueness_condition

        # 更新対象のレコードを正しく特定できているか確認するための検証条件を取得
        required_condition = if @model.parent
                               key = @model.parent_foreign_key

                               { key => @model_attributes[key] }
                             else
                               @plan.value_of(:required_condition)
                             end

        # 検証条件は、必ず値がなければならない
        return nil if required_condition.any? { |_k, v| ! presence_value?(v) }

        # インポートされてきた、レコードを特定する条件が、誤った値でないかどうかを、
        # 特定されるレコードが、更新すべき正しいレコードであるかチェックするための
        # 検証条件とマージして、データベースに登録されているか確認する
        verified_condition = uniqueness_condition.merge(required_condition)

        @model.find_activerecord_by!(verified_condition).__send__(@identified_column_name)
      rescue ::ActiveRecord::RecordNotFound => e
        # ID属性が指定されているのに、データベースに見つからない場合はエラーにする
        raise e if identified_value
      end

      def find_unique_condition
        unique_indexes = @plan.pickup_value_for(@model, :unique_indexes, [])

        # ユニーク条件が指定されていないなら終了
        return nil if unique_indexes.empty?

        unique_condition = unique_indexes.map do |key|
          [key, @model_attributes[key]]
        end.to_h

        # ユニーク条件は、必ず値がなければならない
        return nil if unique_condition.any? { |_k, v| ! presence_value?(v) }

        unique_condition
      end
    end
  end
end
