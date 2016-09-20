module ActiveRecord
  module Bixformer
    module Attribute
      class Enumerize < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record_attribute_value)
          record_attribute_value = record_attribute_value.to_s

          @model.activerecord_constant.__send__(@name).options.find do |text, key|
            key == record_attribute_value
          end&.first
        end

        def import(value)
          return nil if value.blank?

          @model.activerecord_constant.__send__(@name).options.to_h[value.strip] or
            raise ArgumentError.new "Not acceptable enumerize value : #{value}"
        end
      end
    end
  end
end
