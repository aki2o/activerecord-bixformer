require 'active_record'

module ActiveRecord
  module Bixformer
    module Runner
      class Base
        def initialize(format)
          @format   = format
          @modelers = []
        end

        def add_modeler(*modelers)
          modelers.each do |modeler|
            modeler.format = @format

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

        def detect_modeler
          available_modelers.first
        end
      end
    end
  end
end
