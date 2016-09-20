module ActiveRecord
  module Bixformer
    module Attribute
      class Base
        attr_reader :name, :model, :options

        def initialize(model, attribute_name, options)
          @model   = model
          @name    = attribute_name
          @options = (options.is_a?(::Hash) ? options : {}).with_indifferent_access
        end

        def export(record_attribute_value)
          record_attribute_value
        end

        def import(value)
          value
        end
      end
    end
  end
end
