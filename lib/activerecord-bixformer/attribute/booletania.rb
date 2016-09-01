module ActiveRecord
  module Bixformer
    module Attribute
      class Booletania < ::ActiveRecord::Bixformer::Attribute::Base
        def make_export_value(active_record_value)
          return nil unless @model.data_source

          @model.data_source.__send__("#{@name}_text")
        end

        def make_import_value(value)
          return nil unless value

          @model.activerecord_constant.__send__("#{@name}_options").find do |options|
            options.first == value.strip
          end&.last
        end
      end
    end
  end
end
