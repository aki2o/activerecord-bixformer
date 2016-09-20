module ActiveRecord
  module Bixformer
    module Attribute
      class Booletania < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record_attribute_value)
          @model.activerecord_constant.__send__("#{@name}_options").find do |text, bool|
            bool == record_attribute_value
          end&.first
        end

        def import(value)
          return nil unless value

          @model.activerecord_constant.__send__("#{@name}_options").to_h[value.strip]
        end
      end
    end
  end
end
