module ActiveRecord
  module Bixformer
    module Attribute
      class Enumerize < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(active_record_value)
          active_record_value = active_record_value.to_s

          @model.activerecord_constant.__send__(@name).options.find do |text, key|
            key == active_record_value
          end&.first
        end

        def make_import_value(value)
          return nil if value.blank?

          @model.activerecord_constant.__send__(@name).options.to_h[value.strip] or
            raise ArgumentError.new "Not acceptable enumerize value : #{value}"
        end
      end
    end
  end
end
