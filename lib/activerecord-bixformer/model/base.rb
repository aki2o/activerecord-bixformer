module ActiveRecord
  module Bixformer
    module Model
      # @attr_reader [String] name
      #   the name or association name of handled ActiveRecord
      # @attr_reader [ActiveRecord::Bixformer::Model::Base] parent
      #   the instance has parent association.
      # @attr_reader [Hash<String, ActiveRecord::Bixformer::Attribute::Base>] attributes
      #   the import/export target attribute names and its instance.
      # @attr_reader [Array<String>] optional_attributes
      #   the list of attribute name to not make key if its value is blank.
      # @attr_reader [Hash<String, ActiveRecord::Bixformer::Model::Base>] associations
      #   the import/export target association names and its instance.
      # @attr_reader [ActiveRecord::Bixformer::Translator::I18n] translator
      # @attr_reader [ActiveRecord::Bixformer::Plan::Base] plan
      #   active plan in the import/export process.
      class Base
        include ::ActiveRecord::Bixformer::ImportValueValidatable

        attr_reader :name, :options, :parent, :attributes, :associations,
                    :optional_attributes, :translator

        def initialize(model_or_association_name, options)
          @name         = model_or_association_name.to_s
          @options      = (options.is_a?(::Hash) ? options : {}).with_indifferent_access
          @associations = []
        end

        def setup(plan)
          @plan = ActiveRecord::Bixformer::PlanAccessor.new(plan)

          entry = @plan.pickup_value_for(self, :entry, {})

          @attributes = (entry[:attributes] || {}).map do |attribute_name, attribute_value|
            attribute_type, attribute_options = @plan.parse_to_type_and_options(attribute_value)

            @plan.new_module_instance(:attribute, attribute_type, self, attribute_name, attribute_options)
          end

          @optional_attributes = @plan.pickup_value_for(self, :optional_attributes, [])
          @default_values      = @plan.pickup_value_for(self, :default_values, {})

          # At present, translation function is only i18n
          @translator = ::ActiveRecord::Bixformer::Translator::I18n.new

          @translator.config = @plan.value_of(:translation_config).dup
          @translator.model  = self
        end

        def plan
          @plan.raw_value
        end

        def set_parent(model)
          @parent = model
        end

        def parents
          @parent ? [*parent.parents, @parent] : []
        end

        # @return [String] the foreign key name to associate to parent ActiveRecord.
        def parent_foreign_key
          return nil unless @parent

          @parent_foreign_key ||= @parent.activerecord_constant.reflections[@name].foreign_key
        end

        def add_association(model)
          @associations.push(model)

          model.set_parent(self)
        end

        # @return [Constant] the constant value of handling ActiveRecord.
        def activerecord_constant
          @activerecord_constant ||=
            if @parent
              @parent.activerecord_constant.reflections[@name].table_name.classify.constantize
            else
              @name.camelize.constantize
            end
        end

        def find_record_by!(condition)
          activerecord_constant.find_by!(condition)
        end

        def export(record_or_records)
          # has_one でしか使わない想定なので record_or_records は ActiveRecord::Base のはず
          values = @attributes.map do |attr|
            value_reader    = attr.options[:reader] || attr.name
            attribute_value = record_or_records && record_or_records.__send__(value_reader)

            [csv_title(attr.name), attr.export(attribute_value)]
          end.to_h.with_indifferent_access

          @associations.inject(values) do |each_values, association|
            association_value = record_or_records && record_or_records.__send__(association.name)

            association_value = association_value.to_a if association_value.is_a?(::ActiveRecord::Relation)

            each_values.merge(association.export(association_value))
          end
        end

        private

        def make_each_attribute_import_value(parent_record_id = nil, &block)
          values     = {}.with_indifferent_access
          normalizer = ::ActiveRecord::Bixformer::AssignableAttributesNormalizer.new(plan, self, parent_record_id)

          @attributes.each do |attr|
            attribute_value = block.call(attr)

            attribute_value = @default_values[attr.name] unless presence_value?(attribute_value)

            # 取り込み時は、オプショナルな属性では、空と思われる値は取り込まない
            next if ! presence_value?(attribute_value) &&
                    @optional_attributes.include?(attr.name.to_s)

            values[attr.name] = attribute_value
          end

          normalizer.normalize(values)
        end

        def make_each_association_import_value(values, &block)
          self_record_id = values[activerecord_constant.primary_key]

          @associations.each do |association|
            association_value = block.call(association, self_record_id)

            if association_value.is_a?(::Array)
              # has_many な場合は、配列が返ってくるが、空と思われる要素は結果に含めない
              association_value = association_value.reject { |v| ! presence_value?(v) }
            end

            # 取り込み時は、オプショナルな関連では、空と思われる値は取り込まない
            next if ! presence_value?(association_value) &&
                    @optional_attributes.include?(association.name.to_s)

            values["#{association.name}_attributes".to_sym] = association_value
          end

          values
        end
      end
    end
  end
end
