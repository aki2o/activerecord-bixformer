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
            define_method "bixformer_#{timing}_#{target}" do |body, options = {}|
              callback_store = self.__send__("__bixformer_#{target}_callbacks[#{timing}]") || {}

              if callback_store.empty?
                self.__send__("__bixformer_#{target}_callbacks[#{timing}]=", callback_store)
              end

              key = callback_store_key(options)

              callback_store[key] = options.merge({ body: body })
            end
          end
        end
      end

      private

      def self.callback_store_key(options)
        
      end

      def run_callback(target, options, &body)
        before_callback = callback(target, :before, options)

        if before_callback
          return nil unless before_callback.call
        end

        result = yield body

        after_callback = callback(target, :after, options)

        if after_callback
          after_callback.call(result)
        else
          result
        end
      end

      def callback(target, timing, options)
        callback = self.__send__("__bixformer_#{target}_callbacks[#{timing}]")

        return nil if options[:on] && options[:on] != callback[:options][:on]

        callback[:body]
      end
    end
  end
end
