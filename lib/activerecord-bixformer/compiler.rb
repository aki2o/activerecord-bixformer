module ActiveRecord
  module Bixformer
    class Compiler
      def initialize(format, plan)
        plan.__bixformer_format = format.to_s

        @model_name = plan.class.__bixformer_model
        @plan       = ActiveRecord::Bixformer::PlanAccessor.new(plan)
      end

      def compile
        model_type, model_options = @plan.parse_to_type_and_options(@plan.value_of(:entry)[:type])

        model = @plan.new_module_instance(:model, model_type, @model_name, model_options)

        compile_model(model)

        model
      end

      def should_be_included
        compile.should_be_included
      end

      private

      def compile_model(model)
        model.setup(@plan.raw_value)

        compile_associations(model)
      end

      def compile_associations(parent_model)
        association_entries = @plan.pickup_value_for(parent_model, :entry, {})[:associations] || {}

        association_entries.each do |association_name, association_entry|
          association_type, association_options = @plan.parse_to_type_and_options(association_entry[:type])
          association_constant                  = @plan.find_module_constant(:model, association_type)

          association_model = association_constant.new(association_name, association_options)

          parent_model.add_association(association_model)

          compile_model(association_model)
        end
      end
    end
  end
end
