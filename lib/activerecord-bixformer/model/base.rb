module ActiveRecord
  module Bixformer
    module Model
      class Base
        attr_accessor :data_source,
                      :activerecord_id

        attr_reader :name,
                    :parent,
                    :optional_attributes,
                    :association_map

        class << self
          def new_as_association_for_import(parent, association_name, options)
            raise ::NotImplementedError.new("You must implement #{self.class}##{__method__}")
          end

          def new_as_association_for_export(parent, association_name, options)
            model = self.class.new(association_name, options)

            model.data_source = parent.data_source.__send__(association_name) # parent.data_source is ActiveRecord::Base

            unless model.data_source.is_a?(::ActiveRecord::Base)
              parent_name = model.parents.map(&:name).join('.')

              raise ::ArgumentError.new("#{parent_name}.#{association_name} is not a ActiveRecord instance")
            end

            model
          end
        end

        def initialize(model_or_association_name, options = {})
          @name            = model_or_association_name
          @options         = options
          @association_map = {}
        end

        def setup_with_modeler(modeler)
          @modeler = modeler

          entry_definitions = @modeler.config_value_for(self, :entry_definitions, {})

          @attribute_map = (entry_definitions[:attributes] || {}).map do |attribute_name, attribute_type|
            attribute = @modeler.new_module_instance(:attribute, attribute_type, self, attribute_name)

            [attribute_name, attribute]
          end.to_h

          @optional_attributes = @modeler.config_value_for(self, :optional_attributes, [])
          @default_value_map   = @modeler.config_value_for(self, :default_value_map, {})
        end

        def set_parent(model)
          @parent = model
        end

        def parents
          @parent ? [*parent.parents, @parent] : []
        end

        def parent_foreign_key
          return nil unless @parent

          @parent.activerecord_constant.reflections[@name.to_s].foreign_key
        end

        def add_association(model_or_models)
          models = model_or_models.is_a?(::Array) ? model_or_models : [model_or_models]

          association_name = models.first.name

          @association_map[association_name] = model_or_models

          models.each { |model| model.set_parent(self) }
        end

        def activerecord_constant
          if @parent
            @parent.activerecord_constant.reflections[@name.to_s].table_name.classify.constantize
          else
            @name.to_s.classify.constantize
          end
        end

        def generate_export_value_map
          @attribute_map.keys.map do |attribute_name|
            [attribute_name, make_export_value(attribute_name)]
          end.to_h
        end

        def generate_import_value_map
          value_map = {}

          @attribute_map.keys.each do |attribute_name|
            attribute_value = make_import_value(attribute_name) || @default_value_map[attribute_name]

            # 取り込み時は、オプショナルな属性では、空と思われる値は取り込まない
            next if attribute_value.blank? &&
                    @optional_attributes.include?(attribute_name)

            value_map[attribute_name] = attribute_value
          end

          value_map
        end

        private

        def make_export_value(attribute_name)
          return nil unless @data_source

          attribute                   = @attribute_map[attribute_name]
          data_source_attribute_value = @data_source.__send__(attribute_name)

          attribute.make_export_value(data_source_attribute_value)
        end

        def make_import_value(attribute_name)
          fail ::NotImplementedError.new("You must implement #{self.class}##{__method__}")
        end
      end
    end
  end
end