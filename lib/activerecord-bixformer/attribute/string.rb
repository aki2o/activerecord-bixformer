module ActiveRecord
  module Bixformer
    module Attribute
      class String < ::ActiveRecord::Bixformer::Attribute::Base
        def export(activerecord_value)
          activerecord_value.to_s
        end

        def import(value)
          value.to_s.strip.presence
        end
      end
    end
  end
end
