module ActiveRecord
  module Bixformer
    module ModelCallback
      extend ActiveSupport::Concern

      included do
        class_attribute :__bixformer_export_callbacks, instance_writer: false
        class_attribute :__bixformer_import_callbacks, instance_writer: false

        private

        def self.bixformer_callback_key(options)
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
              unless __send__("__bixformer_#{target}_callbacks")
                __send__("__bixformer_#{target}_callbacks=", {})
              end

              store   = __send__("__bixformer_#{target}_callbacks")[timing] ||= {}
              options = callback.extract_options!.with_indifferent_access
              key     = bixformer_callback_key(options)

              store[key] = options.merge(body: block ? block : options[:body] || callback.first)
            end
          end
        end
      end

      private

      def run_bixformer_callback(target, options = {}, &body)
        fetcher = -> (timing) do
          return unless __send__("__bixformer_#{target}_callbacks")

          store  = __send__("__bixformer_#{target}_callbacks")[timing] || {}
          key    = self.class.bixformer_callback_key(options)
          values = store[key] || {}

          values[:body]
        end

        invoker = -> (callback, args_required: false, args_value: nil, &block) do
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

        options = options.with_indifferent_access

        before_callback = fetcher.call(:before)
        if before_callback
          return nil unless invoker.call(before_callback)
        end

        around_callback = fetcher.call(:around)
        result          = invoker.call(around_callback, &body)

        after_callback = fetcher.call(:after)
        invoker.call(after_callback, args_required: true, args_value: result) if after_callback

        result
      end
    end
  end
end
