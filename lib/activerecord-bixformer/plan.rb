module ActiveRecord
  module Bixformer
    module Plan
      extend ActiveSupport::Concern

      included do
        attr_accessor :__bixformer_format

        class_attribute :__bixformer_model
        class_attribute :__bixformer_namespace
        class_attribute :__bixformer_entry
        class_attribute :__bixformer_preferred_skip_attributes
        class_attribute :__bixformer_required_attributes
        class_attribute :__bixformer_unique_attributes
        class_attribute :__bixformer_required_condition
        class_attribute :__bixformer_default_values
        class_attribute :__bixformer_translation_config

        self.__bixformer_entry                     = {}
        self.__bixformer_preferred_skip_attributes = []
        self.__bixformer_required_attributes       = []
        self.__bixformer_unique_attributes         = []
        self.__bixformer_required_condition        = {}
        self.__bixformer_default_values            = {}
        self.__bixformer_translation_config        = { scope: :bixformer, extend_scopes: [] }
      end

      module ClassMethods
        def bixformer_for(model_name)
          self.__bixformer_model = model_name
        end

        def bixformer_load_namespace(namespace)
          self.__bixformer_namespace = namespace
        end

        [
          :entry, :preferred_skip_attributes, :required_attributes, :unique_attributes,
          :required_condition, :default_values, :translation_config
        ].each do |config_name|
          define_method "bixformer_#{config_name}" do |v|
            self.__send__("__bixformer_#{config_name}=", v)
          end
        end
      end
    end
  end
end
