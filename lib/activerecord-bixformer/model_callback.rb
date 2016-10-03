module ActiveRecord
  module Bixformer
    module ModelCallback
      extend ActiveSupport::Concern

      included do
        class_attribute :__bixformer_export_callbacks
        class_attribute :__bixformer_import_callbacks

        self.__bixformer_export_callbacks = {}
        self.__bixformer_import_callbacks = {}

        private

        def self.callback_store_key(options)
          if options[:on]
            "on:#{options[:on]}"
          elsif options[:type]
            "type:#{options[:type]}"
          else
            "global"
          end
        end
      end

      module ClassMethods
        [:export, :import].each do |target|
          [:before, :around, :after].each do |timing|
            define_method "bixformer_#{timing}_#{target}" do |*callback, &block|
              callback_store = self.__send__("__bixformer_#{target}_callbacks")[timing] ||= {}

              options = callback.extract_options!.with_indifferent_access
              key     = callback_store_key(options)

              callback_store[key] = options.merge(
                body: block ? block : options[:body] || callback.first
              )
            end
          end
        end
      end

      private

      def run_callback(target, options = {}, &body)
        options = options.with_indifferent_access

        before_callback = callback(target, :before, options)
        if before_callback
          return nil unless invoke_callback(before_callback)
        end

        around_callback = callback(target, :around, options)
        result          = invoke_callback(around_callback, &body)

        after_callback = callback(target, :after, options)
        invoke_callback(after_callback, args_required: true, args_value: result) if after_callback

        result
      end

      def invoke_callback(callback, args_required: false, args_value: nil, &block)
        if callback.is_a?(::Proc)
          if block
            self.instance_exec block, &callback
          elsif args_required
            self.instance_exec args_value, &callback
          else
            self.instance_exec &callback
          end
        elsif callback.is_a?(::Symbol) || callback.is_a?(::String)
          if block
            self.__send__(callback, &block)
          elsif args_required
            self.__send__(callback, args_value)
          else
            self.__send__(callback)
          end
        elsif block
          yield block
        end
      end

      def callback(target, timing, options)
        callback_store  = self.__send__("__bixformer_#{target}_callbacks")[timing] || {}
        callback_values = callback_store[self.class.callback_store_key(options)] || {}

        callback_values[:body]
      end
    end
  end
end
