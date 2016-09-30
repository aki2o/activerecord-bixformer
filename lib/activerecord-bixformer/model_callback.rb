module ActiveRecord
  module Bixformer
    module ModelCallback
      extend ActiveSupport::Concern

      included do
        class_attribute :__bixformer_export_callbacks
        class_attribute :__bixformer_import_callbacks

        self.__bixformer_export_callbacks = {}
        self.__bixformer_import_callbacks = {}
      end

      module ClassMethods
        [:export, :import].each do |target|
          [:before, :after].each do |timing|
            define_method "bixformer_#{timing}_#{target}" do |callback, *options|
            end
          end
        end
      end
    end
  end
end
