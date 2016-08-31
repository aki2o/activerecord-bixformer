module ActiveRecord
  module Bixformer
    module Translator
      class I18n
        attr_accessor :settings, :model, :attribute_arguments_map

        def initialize
          @attribute_arguments_map = {}
        end

        def translate_attribute(attribute_name)
          root_scope    = normalize_scope_value(@settings[:root_scope] || 'activerecord.attributes')
          extend_scopes = @settings[:extend_scopes] || []
          arguments     = ( @attribute_arguments_map[attribute_name] || {} ).merge(raise: true)
          model_key     = [*@model.parents, @model].map(&:name).join('/')

          extend_scopes.each do |extend_scope|
            extend_scope = normalize_scope_value(extend_scope)
            extend_scope = '.' + extend_scope if extend_scope.present?

            begin
              # 成功なら、それを返却
              return ::I18n.t("#{root_scope}#{extend_scope}.#{model_key}.#{attribute_name}", arguments)
            rescue ::I18n::MissingTranslationData
              # 見つからなければ、次を試す
              next
            end
          end

          # 拡張部分を使った translation が見つからなかった場合は、拡張部分なしで translation を実行
          ::I18n.t("#{root_scope}.#{model_key}.#{attribute_name}", arguments)
        end

        private

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