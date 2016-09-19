module ActiveRecord
  module Bixformer
    module Attribute
      class Date < ::ActiveRecord::Bixformer::Attribute::Base
        def export(activerecord_value)
          return nil unless activerecord_value

          activerecord_value.to_s(option_format)
        end

        def import(value)
          return nil if value.blank?

          begin
            ::Date.parse(value)
          rescue => e
            format_string = ::Date::DATE_FORMATS[option_format]

            if format_string
              ::Date.strptime(value, format_string)
            else
              raise e
            end
          end
        end

        private

        def option_format
          (@options.is_a?(::Hash) && @options[:format]) || :default
        end
      end
    end
  end
end
