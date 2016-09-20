module ActiveRecord
  module Bixformer
    module Attribute
      class Boolean < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record_attribute_value)
          true_value = (@options.is_a?(::Hash) && @options[:true]) || 'true'
          false_value = (@options.is_a?(::Hash) && @options[:false]) || 'false'

          record_attribute_value.present? ? true_value : false_value
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
