module ActiveRecord
  module Bixformer
    module Attribute
      class Enumrize < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(active_record_value)
          return nil unless active_record_value

          @model.data_source.__send__("#{@name}_text")
        end

        def make_import_value(value)
          return nil unless value

          @model.activerecord_constant.__send__(@name).options.to_h[value.strip]
        end
      end
    end
  end
end
