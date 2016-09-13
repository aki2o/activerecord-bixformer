module ActiveRecord
  module Bixformer
    module Translator
      class I18n
        attr_accessor :config, :model, :attribute_arguments_map, :model_arguments

        def initialize
          @attribute_arguments_map = {}
          @model_arguments         = {}
        end

        def translate_attribute(attribute_name)
          translate('attributes', ".#{attribute_name}", @attribute_arguments_map[attribute_name])
        end

        def translate_model
          translate('models', '', @model_arguments)
        end

        private

        def translate(type_key, extra_key, arguments)
          root_scope    = normalize_scope_value(@config[:scope] || 'activerecord')
          extend_scopes = @config[:extend_scopes] || []
          arguments     = arguments || {}
          model_key     = [*@model.parents, @model].map(&:name).join('/')

          key_candidates = [*extend_scopes.map { |s| ".#{normalize_scope_value(s)}" }, ''].map do |extend_scope|
            "#{root_scope}#{extend_scope}.#{type_key}.#{model_key}#{extra_key}"
          end

          found_key = key_candidates.find { |key| ::I18n.exists?(key) }

          raise ::I18n::MissingTranslationData.new(::I18n.locale, key_candidates.last, arguments) unless found_key

          ::I18n.t(found_key, arguments || {})
        end

        def normalize_scope_value(scope_value)
          return nil if scope_value.blank?

          scope_value = scope_value.map(&:to_s).join(".") if scope_value.is_a?(::Array)

          # delimiter が付いていたら削除
          scope_value.to_s.sub(/\A\./, '').sub(/\.\z/, '')
        end
      end
    end
  end
end
