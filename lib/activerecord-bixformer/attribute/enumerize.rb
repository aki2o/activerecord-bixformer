module ActiveRecord
  module Bixformer
    module Attribute
      class Enumerize < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(active_record_value)
          return nil unless @model.data_source

          @model.data_source.__send__("#{@name}_text")
        end

        def make_import_value(value)
          return nil if value.blank?

          @model.activerecord_constant.__send__(@name).options.to_h[value.strip]
        end
      end
    end
  end
end
