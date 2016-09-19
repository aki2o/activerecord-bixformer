module ActiveRecord
  module Bixformer
    module Attribute
      class Booletania < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(activerecord_value)
          @model.activerecord_constant.__send__("#{@name}_options").find do |text, bool|
            bool == activerecord_value
          end&.first
        end

        def make_import_value(value)
          return nil unless value

          @model.activerecord_constant.__send__("#{@name}_options").to_h[value.strip]
        end
      end
    end
  end
end
