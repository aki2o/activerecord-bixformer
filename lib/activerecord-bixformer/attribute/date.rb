module ActiveRecord
  module Bixformer
    module Attribute
      class Date < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record)
          record_attribute_value = record_attribute_value(record)

          return nil unless record_attribute_value

          record_attribute_value.to_s(option_format)
        end

        def import(value)
          return nil if value.blank?

          result = begin
                     ::Date.parse(value)
                   rescue
                     format_string = ::Date::DATE_FORMATS[option_format]

                     ::Date.strptime(value, format_string) rescue nil if format_string
                   end

          return result if result

          raise ::ActiveRecord::Bixformer::AttributeError.new(self, value) if @options[:raise]
        end

        private

        def option_format
          (@options.is_a?(::Hash) && @options[:format]) || :default
        end
      end
    end
  end
end
