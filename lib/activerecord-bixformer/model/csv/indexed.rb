module ActiveRecord
  module Bixformer
    module Model
      module Csv
        class Indexed < ::ActiveRecord::Bixformer::Model::Csv::Base
          class << self
            def new_as_association_for_import(parent, association_name, options)
              limit_size = options[:size] || 1

              (1..limit_size).map do |index|
                model = self.new(association_name, options.merge(index: index))

                model.data_source = parent.data_source # parent.data_source is CSV::Row

                model
              end
            end

            def new_as_association_for_export(parent, association_name, options)
              limit_size   = options[:size] || 1
              associations = parent.data_source ? parent.data_source.__send__(association_name).to_a : []

              (1..limit_size).map do |index|
                model = self.new(association_name, options.merge(index: index))

                model.data_source = associations[index - 1]

                model
              end
            end
          end

          def setup_with_modeler(modeler)
            super

            @translator.model_arguments = { index: @options[:index] }

            @translator.attribute_arguments_map = @attribute_map.keys.map do |attribute_name|
              [attribute_name, { index: @options[:index] }]
            end.to_h
          end

          def csv_title(attribute_name)
            if parents.find { |parent| parent.is_a?(ActiveRecord::Bixformer::Model::Csv::Indexed) }
              parents.map { |parent| parent.translator.translate_model }.join + super
            else
              super
            end
          end
        end
      end
    end
  end
end
