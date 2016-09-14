module ActiveRecord
  module Bixformer
    module Model
      # @attr [Object] data_source
      # @attr [Integer] activerecord_id
      # @attr_reader [String] name
      #   the name or association name of handled ActiveRecord
      # @attr_reader [ActiveRecord::Bixformer::Model::Base] parent
      #   the instance has parent association.
      # @attr_reader [Hash<String, ActiveRecord::Bixformer::Attribute::Base>] attribute_map
      #   the import/export target attribute names and its instance.
      # @attr_reader [Array<String>] optional_attributes
      #   the list of attribute name to not make key if its value is blank.
      # @attr_reader [Hash<String, ActiveRecord::Bixformer::Model::Base>] association_map
      #   the import/export target association names and its instance.
      # @attr_reader [ActiveRecord::Bixformer::Translator::I18n] translator
      # @attr_reader [ActiveRecord::Bixformer::Modeler::Base] modeler
      #   active modeler in the import/export process.
      class Base
        attr_accessor :data_source,
                      :activerecord_id

        attr_reader :name,
                    :parent,
                    :attribute_map,
                    :optional_attributes,
                    :association_map,
                    :translator,
                    :modeler

        class << self
          def new_as_association_for_import(parent, association_name, options)
            raise ::NotImplementedError.new "You must implement #{self.class}##{__method__}"
          end

          def new_as_association_for_export(parent, association_name, options)
            model = self.new(association_name, options)

            model.data_source = parent.data_source && parent.data_source.__send__(association_name) # parent.data_source is ActiveRecord::Base

            unless model.data_source.is_a?(::ActiveRecord::Base)
              parent_name = model.parents.map(&:name).join('.')

              raise ::ArgumentError.new "#{parent_name}.#{association_name} is not a ActiveRecord instance"
            end

            model
          end
        end

        def initialize(model_or_association_name, options)
          @name            = model_or_association_name.to_s
          @options         = options
          @association_map = {}
        end

        def setup_with_modeler(modeler)
          @modeler = modeler

          entry_definition = @modeler.config_value_for(self, :entry_definition, {})

          @attribute_map = (entry_definition[:attributes] || {}).map do |attribute_name, attribute_value|
            attribute_type, attribute_options = @modeler.parse_to_type_and_options(attribute_value)

            attribute = @modeler.new_module_instance(:attribute, attribute_type, self, attribute_name, attribute_options)

            [attribute_name, attribute]
          end.to_h

          @optional_attributes = @modeler.config_value_for(self, :optional_attributes, [])
          @default_values   = @modeler.config_value_for(self, :default_values, {})

          # At present, translation function is only i18n
          @translator = ::ActiveRecord::Bixformer::Translator::I18n.new

          @translator.config = @modeler.translation_config.dup
          @translator.model    = self
        end

        def set_parent(model)
          @parent = model
        end

        def parents
          @parent ? [*parent.parents, @parent] : []
        end

        # @return [String] the foreign key name to associate to parent ActiveRecord.
        def parent_foreign_key
          return nil unless @parent

          @parent_foreign_key ||= @parent.activerecord_constant.reflections[@name].foreign_key
        end

        def add_association(model_or_models)
          models = model_or_models.is_a?(::Array) ? model_or_models : [model_or_models]

          association_name = models.first.name

          @association_map[association_name] = model_or_models

          models.each { |model| model.set_parent(self) }
        end

        # @return [Constant] the constant value of handling ActiveRecord.
        def activerecord_constant
          @activerecord_constant ||=
            if @parent
              @parent.activerecord_constant.reflections[@name].table_name.classify.constantize
            else
              @name.camelize.constantize
            end
        end

        def generate_export_value_map
          @attribute_map.keys.map do |attribute_name|
            [attribute_name, make_export_value(attribute_name)]
          end.to_h.with_indifferent_access
        end

        def generate_import_value_map
          value_map = {}.with_indifferent_access

          @attribute_map.keys.each do |attribute_name|
            attribute_value = make_import_value(attribute_name)

            attribute_value = @default_values[attribute_name] unless presence_value?(attribute_value)

            # 取り込み時は、オプショナルな属性では、空と思われる値は取り込まない
            next if ! presence_value?(attribute_value) &&
                    @optional_attributes.include?(attribute_name.to_s)

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
          raise ::NotImplementedError.new "You must implement #{self.class}##{__method__}"
        end

        def presence_value?(value)
          case value
          when ::String
            ! value.blank?
          when ::TrueClass, ::FalseClass
            true
          else
            value ? true : false
          end
        end
      end
    end
  end
end
