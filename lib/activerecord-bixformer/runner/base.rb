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
          @modelers
        end

        def detect_modeler
          available_modelers.first || "::ActiveRecord::Bixformer::Modeler::#{@format.to_s.camelize}::Base".constantize.new
        end
      end
    end
  end
end
