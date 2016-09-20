module ActiveRecord
  module Bixformer
    module Attribute
      class Override < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record)
          @model.__send__("override_export_#{@name}", record_attribute_value(record))
        end

        def import(value)
          @model.__send__("override_import_#{@name}", value)
        end
      end
    end
  end
end
