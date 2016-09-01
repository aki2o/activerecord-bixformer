module ActiveRecord
  module Bixformer
    module Attribute
      class Time < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(active_record_value)
          format = (@options.is_a?(::Hash) && @options[:format]) || :default

          active_record_value.to_s(format)
        end
      end
    end
  end
end
