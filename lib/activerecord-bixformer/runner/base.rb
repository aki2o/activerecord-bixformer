require 'active_record'

module ActiveRecord
  module Bixformer
    module Runner
      class Base
        attr_reader :errors

        def initialize(format)
          @format   = format
          @modelers = []
          @errors   = []
        end

        def add_modeler(*modelers)
          modelers.each do |modeler|
            unless modeler.format.to_s == @format.to_s
              raise ArgumentError.new "modeler format unmatches to #{@format} as runner format : #{modeler.format}"
            end

            @modelers.push modeler
          end
        end

        private

        def available_modelers
          if @modelers.empty?
            raise ArgumentError.new "Not exist any available modelers. You have to regist modeler by add_modeler."
          end

          @modelers
        end

        def active_modeler(force_detect = nil)
          return @active_modeler if ! force_detect && @active_modeler

          @active_modeler = detect_modeler
        end

        def detect_modeler
          available_modelers.first
        end
      end
    end
  end
end
