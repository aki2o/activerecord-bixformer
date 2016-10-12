module ActiveRecord
  module Bixformer
    module Attribute
      class Booletania < ::ActiveRecord::Bixformer::Attribute::Base
        def export(record)
          record_attribute_value = record_attribute_value(record)

          @model.activerecord_constant.__send__("#{@name}_options").find do |text, bool|
            bool == record_attribute_value
          end&.first
        end

        def import(value)
          return nil if value.blank?

          value      = value.strip
          boolean_of = @model.activerecord_constant.__send__("#{@name}_options").to_h

          return boolean_of[value] if boolean_of.key?(value)

          raise ::ActiveRecord::Bixformer::DataInvalid.new(self, value) if @options[:raise]
        end
      end
    end
  end
end
