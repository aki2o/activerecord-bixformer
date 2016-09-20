module ActiveRecord
  module Bixformer
    module Attribute
      class String < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record)
          record_attribute_value(record).to_s
        end

        def import(value)
          value.to_s.strip.presence
        end
      end
    end
  end
end
