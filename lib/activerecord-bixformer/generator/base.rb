module ActiveRecord
  module Bixformer
    module Generator
      class Base
        def initialize(modeler, data_source)
          @modeler     = modeler
          @data_source = data_source
        end

        def compile
          return @model if @model

          model_name                = @modeler.model_name
          model_type, model_options = @modeler.parse_to_type_and_options(@modeler.entry_definitions[:type])
          model_type                = resolve_model_type(model_type, model_name)

          @model = @modeler.new_module_instance(:model, model_type, model_name, model_options)

          @model.data_source = @data_source

          compile_model(@model)

          @model
        end

        def generate
          generate_model_value(compile)
        end

        private

        def compile_model(model)
          model.setup_with_modeler(@modeler)

          compile_associations(model)
        end

        def compile_associations(parent_model)
          association_definitions = @modeler.config_value_for(parent_model, :entry_definitions, {})[:associations] || {}

          association_definitions.each do |association_name, association_definition|
            association_type, association_options = @modeler.parse_to_type_and_options(association_definition[:type])
            association_type                      = resolve_model_type(association_type, association_name, parent_model)
            association_constant                  = @modeler.find_module_constant(:model, association_type)

            model_or_models = association_constant.__send__(
              association_generator, parent_model, association_name, association_options
            )

            parent_model.add_association(model_or_models)

            if model_or_models.is_a?(::Array)
              model_or_models.each { |model| compile_model(model) }
            else
              compile_model(model_or_models)
            end
          end
        end

        def resolve_model_type(type_name, model_name, parent_model = nil)
          return type_name unless type_name == :override

          if parent_model
            [*parent_model.parents.map(&:name), parent_model.name, model_name].compact.join('::')
          else
            model_name
          end
        end
      end
    end
  end
end
