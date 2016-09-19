module ActiveRecord
  module Bixformer
    module Attribute
      class Boolean < ::ActiveRecord::Bixformer::Attribute::Base
        def export(activerecord_value)
          true_value = (@options.is_a?(::Hash) && @options[:true]) || 'true'
          false_value = (@options.is_a?(::Hash) && @options[:false]) || 'false'

          activerecord_value.present? ? true_value : false_value
        end

        def import(value)
          true_value = (@options.is_a?(::Hash) && @options[:true]) || 'true'
          false_value = (@options.is_a?(::Hash) && @options[:false]) || 'false'

          case value
          when true_value
            true
          when false_value
            false
          end
        end
      end
    end
  end
end
