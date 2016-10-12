module ActiveRecord
  module Bixformer
    class Errors < Array
      def messages
        map(&:message)
      end

      def full_messages
        map(&:full_message)
      end
    end

    class ImportError < ::StandardError
      attr_reader :model

      def initialize(model)
        @model = model

        super("failed to import #{model.name}")
      end
    end

    class AttributeError < ::StandardError
      def initialize(attribute, value, type)
        @attribute = attribute

        super(generate_message(attribute, type, value))
      end

      def full_message
        options = {
          default: "%{attribute} %{message}",
          attribute: @attribute.model.translate(@attribute.name),
          message: message
        }

        I18n.t(:"errors.format", options)
      end

      private

      # implemented with referencing to https://github.com/rails/rails/blob/517cf249c369d4bca40b1f590ca641d8b717985e/activemodel/lib/active_model/errors.rb#L462
      def generate_message(attribute, type, value)
        model_klass = attribute.model.activerecord_constant
        model_scope = model_klass.i18n_scope

        defaults = if model_scope
                     model_klass.lookup_ancestors.map do |klass|
                       [
                         :"#{model_scope}.errors.models.#{klass.model_name.i18n_key}.attributes.#{attribute.name}.#{type}",
                         :"#{model_scope}.errors.models.#{klass.model_name.i18n_key}.#{type}"
                       ]
                     end
                   else
                     []
                   end

        defaults << :"#{model_scope}.errors.messages.#{type}" if model_scope
        defaults << :"errors.attributes.#{attribute.name}.#{type}"
        defaults << :"errors.messages.#{type}"

        defaults.compact!
        defaults.flatten!

        key = defaults.shift

        options = {
          default: defaults,
          model: model_klass.model_name.human,
          attribute: model_klass.human_attribute_name(attribute.name),
          value: value
        }

        I18n.translate(key, options)
      end
    end

    class DataInvalid < AttributeError
      def initialize(attribute, value)
        super(attribute, value, :invalid)
      end
    end
  end
end
