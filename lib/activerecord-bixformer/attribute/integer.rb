module ActiveRecord
  module Bixformer
    module Attribute
      class Integer < ::ActiveRecord::Bixformer::Attribute::Base
        def import(value)
          return nil if value.blank?

          unless value.strip.match(/\A[0-9]+\z/)
            if @options[:raise]
              raise ::ActiveRecord::Bixformer::AttributeError.new(self, value, :not_an_integer)
            else
              return nil
            end
          end

          numeric_value = value.to_i

          [
            [:greater_than,             -> (o, n) { n >  o }],
            [:greater_than_or_equal_to, -> (o, n) { n >= o }],
            [:less_than,                -> (o, n) { n <  o }],
            [:less_than_or_equal_to,    -> (o, n) { n <= o }],
          ].each do |restrict_name, validator|
            restrict_value = @options[restrict_name]

            next unless restrict_value.is_a?(::Integer)

            next if validator.call(restrict_value, numeric_value)

            if @options[:raise]
              raise ::ActiveRecord::Bixformer::AttributeError.new(self, value, restrict_name, count: restrict_value)
            else
              return nil
            end
          end

          numeric_value
        end
      end
    end
  end
end
