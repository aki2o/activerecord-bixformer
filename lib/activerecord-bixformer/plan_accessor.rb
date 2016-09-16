module ActiveRecord
  module Bixformer
    class PlanAccessor
      def initialize(plan)
        @plan                      = plan
        @module_constant_of        = {}
        @module_load_namespaces_of = {}
      end

      def raw_value
        @plan
      end

      def value_of(config_name)
        @plan.__send__(config_name)
      end

      def pickup_value_for(model, config_name, default_value = nil)
        model_names_without_root = (model.parents.map(&:name) + [model.name]).drop(1)

        # 指定された設定の全設定値を取得
        entire_config_value = @plan.__send__(config_name)

        if entire_config_value.is_a?(::Hash)
          # Hashなら、with_indifferent_accessしておく
          entire_config_value = entire_config_value.with_indifferent_access
        elsif entire_config_value.is_a?(::Array) && entire_config_value.last.is_a?(::Hash)
          # Arrayで最後の要素がHashなら、with_indifferent_accessしておく
          config_value = entire_config_value.pop

          entire_config_value.push config_value.with_indifferent_access
        end

        # その中から、指定のmodelに対応する設定部分を抽出
        config_value = if config_name == :entry
                         find_entry(entire_config_value, model_names_without_root)
                       else
                         find_nested_config_value(entire_config_value, model_names_without_root)
                       end

        if config_value.is_a?(::Array)
          # Arrayで最後の要素がHashの場合、それは子要素の設定値なので、結果に含めない
          config_value.pop if config_value.last.is_a?(::Hash)

          # Arrayなら、要素は文字列化しておく
          config_value = config_value.map { |v| v.to_s }
        end

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

        module_constant = @module_constant_of["#{module_type}/#{name}"]

        return module_constant if module_constant

        namespaces = @module_load_namespaces_of[module_type] ||= module_load_namespaces(module_type)

        namespaces.each do |namespace|
          constant = "#{namespace}::#{name.to_s.camelize}".safe_constantize

          return @module_constant_of["#{module_type}/#{name}"] = constant if constant
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

      def find_entry(config, keys)
        return config ? config.dup : nil if keys.empty?

        key = keys.shift

        find_entry(config[:associations][key], keys)
      end

      def module_load_namespaces(module_type)
        [
          @plan.class.__bixformer_namespace,
          "::ActiveRecord::Bixformer::#{module_type.to_s.camelize}::#{@plan.__bixformer_format.camelize}",
          "::ActiveRecord::Bixformer::#{module_type.to_s.camelize}",
        ].compact
      end
    end
  end
end
