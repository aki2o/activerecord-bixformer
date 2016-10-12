module ActiveRecord
  module Bixformer
    module Attribute
      class Boolean < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record)
          true_value = (@options.is_a?(::Hash) && @options[:true]) || 'true'
          false_value = (@options.is_a?(::Hash) && @options[:false]) || 'false'

          record_attribute_value(record).present? ? true_value : false_value
        end

        def import(value)
          return nil if value.blank?

          true_value = (@options.is_a?(::Hash) && @options[:true]) || 'true'
          false_value = (@options.is_a?(::Hash) && @options[:false]) || 'false'

          case value
          when true_value
            true
          when false_value
            false
          else
            raise ::ActiveRecord::Bixformer::DataInvalid.new(self, value) if @options[:raise]
          end
        end
      end
    end
  end
end
