module ActiveRecord
  module Bixformer
    module Attribute
      class String < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record_attribute_value)
          record_attribute_value.to_s
        end

        def import(value)
          value.to_s.strip.presence
        end
      end
    end
  end
end
