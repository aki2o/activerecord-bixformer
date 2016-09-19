module ActiveRecord
  module Bixformer
    module Attribute
      class Base
        attr_reader :name, :model, :options

        def initialize(model, attribute_name, options)
          @model   = model
          @name    = attribute_name
          @options = options
        end

        def make_export_value(activerecord_value)
          activerecord_value.to_s
        end

        def make_import_value(value)
          value.presence
        end
      end
    end
  end
end
