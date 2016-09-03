module ActiveRecord
  module Bixformer
    module Attribute
      class Time < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(active_record_value)
          return nil unless active_record_value

          active_record_value.to_s(option_format)
        end

        def make_import_value(value)
          return nil if value.blank?

          begin
            ::Time.parse(value)
          rescue => e
            format_string = ::Time::DATE_FORMATS[option_format]

            if format_string
              ::Time.strptime(value, format_string)
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
