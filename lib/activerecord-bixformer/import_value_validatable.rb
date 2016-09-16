module ActiveRecord
  module Bixformer
    module ImportValueValidatable
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
