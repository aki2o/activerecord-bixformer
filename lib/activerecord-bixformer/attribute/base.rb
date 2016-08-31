module ActiveRecord
  module Bixformer
    module Attribute
      class Base
        def initialize(model, attribute_name)
          @model = model
          @name  = attribute_name
        end

        def make_export_value(active_record_value)
          active_record_value.to_s
        end

        def make_import_value(value)
          value.presence
        end
      end
    end
  end
end
