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

        # Add modeler for import/export process definition.
        #
        # A import/export process is designed by a modeler as instance of ActiveRecord:;Bixformer::Modeler::Base.
        # You should call this method at least once before the process start.
        # You are able to add multiple modeler and detect one to design the process using detect_modeler.
        #
        # @param [*Array<ActiveRecord::Bixformer::Modeler::Base>] modelers list of modeler for candidate of available_modelers.
        # @see detect_modeler
        def add_modeler(*modelers)
          modelers.each do |modeler|
            unless modeler.format.to_s == @format.to_s
              raise ArgumentError.new "modeler format unmatches to #{@format} as runner format : #{modeler.format}"
            end

            @modelers.push modeler
          end
        end

        private

        # @return [Array<ActiveRecord::Bixformer::Modeler::Base>] available modelers to design a import/export process.
        def available_modelers
          if @modelers.empty?
            raise ArgumentError.new "Not exist any available modelers. You have to regist modeler by add_modeler."
          end

          @modelers
        end

        # Return a detected modeler by detect_modeler.
        #
        # @param [Boolean] force_detect a result of detect_modeler will be cached.
        #   if this option is true, recall detect_modeler.
        # @return [ActiveRecord::Bixformer::Modeler::Base] a detected modeler by detect_modeler
        def active_modeler(force_detect = nil)
          return @active_modeler if ! force_detect && @active_modeler

          @active_modeler = detect_modeler
        end

        # Return a modeler to design a import/export process.
        #
        # In many case, you should override this method because this returns
        #   just first one in available them in default.
        #
        # @return [ActiveRecord::Bixformer::Modeler::Base] a modeler
        def detect_modeler
          available_modelers.first
        end
      end
    end
  end
end
