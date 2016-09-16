module ActiveRecord
  module Bixformer
    module Plan
      extend ActiveSupport::Concern

      included do
        attr_accessor :__bixformer_format

        class_attribute :__bixformer_model

        class_attribute :__bixformer_namespace
      end

      module ClassMethods
        def bixformer_for(model_name)
          self.__bixformer_model = model_name
        end

        def bixformer_load_namespace(namespace)
          self.__bixformer_namespace = namespace
        end
      end

      def entry
        {}
      end

      def optional_attributes
        []
      end

      def required_attributes
        []
      end

      def unique_indexes
        []
      end

      def required_condition
        {}
      end

      def default_values
        {}
      end

      def translation_config
        {
          scope: :bixformer,
          extend_scopes: []
        }
      end
    end
  end
end
