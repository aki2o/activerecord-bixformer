module ActiveRecord
  module Bixformer
    module Modeler
      class Base
        attr_reader :format

        def initialize(format)
          @format = format
        end

        def model_name
        end

        # type
        # attributes
        # associations
        def entry_definitions
          {}
        end

        def optional_attributes
          []
        end

        def default_value_map
          {}
        end

        def unique_indexes
          []
        end

        def translation_settings
          {
            root_scope: :bixformer,
            extend_scopes: []
          }
        end

        def module_load_namespaces(module_type)
          [
            "::ActiveRecord::Bixformer::#{module_type.to_s.camelize}::#{@format.to_s.camelize}",
            "::ActiveRecord::Bixformer::#{module_type.to_s.camelize}",
          ]
        end

        def config_value_for(model, config_name, default_value = nil)
          model_names_without_root = (model.parents.map(&:name) + [model.name]).drop(1)

          config_value = if config_name == :entry_definitions
                           find_entry_definitions(entry_definitions, model_names_without_root)
                         else
                           find_nested_config_value(__send__(config_name), model_names_without_root)
                         end

          # Arrayで最後の要素がHashの場合、それは子要素の設定値なので、結果に含めない
          config_value.pop if config_value.is_a?(::Array) && config_value.last.is_a?(::Hash)

          config_value || default_value
        end

        def new_module_instance(module_type, name_or_instance, *initializers)
          name_or_instance = :base unless name_or_instance

          name_or_instance = name_or_instance.to_s if name_or_instance.is_a?(::Symbol)

          return name_or_instance unless name_or_instance.is_a?(::String)

          if initializers.size > 0
            find_module_constant(module_type, name_or_instance).new(*initializers)
          else
            find_module_constant(module_type, name_or_instance).new
          end
        end

        def find_module_constant(module_type, name)
          name = :base unless name

          module_load_namespaces(module_type).each do |namespace|
            constant = "#{namespace}::#{name.to_s.camelize}".safe_constantize

            return constant if constant
          end

          raise ::ArgumentError.new "Not found module named #{name.to_s.camelize} in module_load_namespaces('#{module_type}')"
        end

        def parse_to_type_and_options(value)
          value = value.dup if value.is_a?(::Array) || value.is_a?(::Hash)
          type  = value.is_a?(::Array) ? value.shift : value

          arguments = if value.is_a?(::Array) && value.size == 1 && value.first.is_a?(::Hash)
                        value.first
                      elsif value.is_a?(::Array)
                        value
                      else
                        nil
                      end

          [type, arguments]
        end

        private

        def find_nested_config_value(config, keys)
          return config ? config.dup : nil if keys.empty?

          key = keys.shift

          # config が Array なら、子要素は最後の要素にハッシュで定義してあるはず
          config_map = config.is_a?(::Array) ? config.last : config

          return nil unless config_map.is_a?(::Hash)

          find_nested_config_value(config_map[key], keys)
        end

        def find_entry_definitions(config, keys)
          return config ? config.dup : nil if keys.empty?

          key = keys.shift

          find_entry_definitions(config[:associations][key], keys)
        end
      end
    end
  end
end
