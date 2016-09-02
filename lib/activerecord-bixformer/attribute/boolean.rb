module ActiveRecord
  module Bixformer
    module Attribute
      class Boolean < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(active_record_value)
          true_value = (@options.is_a?(::Hash) && @options[:true]) || 'true'
          false_value = (@options.is_a?(::Hash) && @options[:false]) || 'false'

          active_record_value.present? ? true_value : false_value
        end

        def make_import_value(value)
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
