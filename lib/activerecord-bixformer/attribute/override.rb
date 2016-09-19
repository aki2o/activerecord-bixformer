module ActiveRecord
  module Bixformer
    module Attribute
      class Override < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(activerecord_value)
          @model.__send__("override_export_#{@name}", activerecord_value)
        end

        def make_import_value(value)
          @model.__send__("override_import_#{@name}", value)
        end
      end
    end
  end
end
