module ActiveRecord
  module Bixformer
    module Attribute
      class Override < ::ActiveRecord::Bixformer::Attribute::Base
        def export(activerecord_value)
          @model.__send__("override_export_#{@name}", activerecord_value)
        end

        def import(value)
          @model.__send__("override_import_#{@name}", value)
        end
      end
    end
  end
end
