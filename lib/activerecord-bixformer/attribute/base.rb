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

        def export(activerecord_value)
          activerecord_value
        end

        def import(value)
          value
        end
      end
    end
  end
end
