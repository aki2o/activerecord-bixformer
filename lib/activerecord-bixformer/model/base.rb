module ActiveRecord
  module Bixformer
    module Model
      # @attr_reader [String] name
      #   the name or association name of handled ActiveRecord
      # @attr_reader [ActiveRecord::Bixformer::Model::Base] parent
      #   the instance has parent association.
      # @attr_reader [Hash<String, ActiveRecord::Bixformer::Attribute::Base>] attributes
      #   the import/export target attribute names and its instance.
      # @attr_reader [Array<String>] preferred_skip_attributes
      #   the list of attribute name to not make key if its value is blank.
      # @attr_reader [Hash<String, ActiveRecord::Bixformer::Model::Base>] associations
      #   the import/export target association names and its instance.
      # @attr_reader [ActiveRecord::Bixformer::Translator::I18n] translator
      class Base
        include ::ActiveRecord::Bixformer::ImportValueValidatable
        include ::ActiveRecord::Bixformer::ModelCallback

        attr_reader :name, :options, :parent, :attributes, :associations,
                    :preferred_skip_attributes, :translator, :errors

        def initialize(model_or_association_name, options)
          @name         = model_or_association_name.to_s
          @options      = (options.is_a?(::Hash) ? options : {}).with_indifferent_access
          @associations = []
          @errors       = ::ActiveRecord::Bixformer::Errors.new
        end

        def setup(plan)
          @plan = ActiveRecord::Bixformer::PlanAccessor.new(plan)

          entry = @plan.pickup_value_for(self, :entry, {})

          @attributes = (entry[:attributes] || {}).map do |attribute_name, attribute_value|
            attribute_type, attribute_options = @plan.parse_to_type_and_options(attribute_value)

            @plan.new_module_instance(:attribute, attribute_type, self, attribute_name, attribute_options)
          end

          @preferred_skip_attributes = @plan.pickup_value_for(self, :preferred_skip_attributes, [])
          @default_values            = @plan.pickup_value_for(self, :default_values, {})
          @sort_indexes              = @plan.pickup_value_for(self, :sort_indexes, {})

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
              @parent.activerecord_constant.reflections[@name].class_name.constantize
            else
              @name.camelize.constantize
            end
        end

        def should_be_included
          arr  = []
          hash = {}

          symbolizer = -> (value) do
            case value
            when ::Hash
              value.map { |k, v| [k.to_sym, symbolizer.call(v)]}.to_h
            when ::Array
              value.map { |v| symbolizer.call(v) }
            when ::String
              value.to_sym
            else
              value
            end
          end

          @attributes.each do |attr|
            attr_should_be_included = attr.should_be_included

            next unless attr_should_be_included

            if attr_should_be_included.is_a?(::Hash)
              hash.merge!(symbolizer.call(attr_should_be_included))
            elsif attr_should_be_included.is_a?(::Array)
              arr.push *symbolizer.call(attr_should_be_included)
            else
              arr.push symbolizer.call(attr_should_be_included)
            end
          end

          @associations.each do |assoc|
            assoc_should_be_included = assoc.should_be_included

            if assoc_should_be_included.empty?
              arr.push assoc.name.to_sym
            else
              hash[assoc.name.to_sym] = assoc_should_be_included
            end
          end

          if hash.empty? && arr.empty?
            []
          elsif hash.empty?
            arr
          elsif arr.empty?
            hash
          else
            [*arr, hash]
          end
        end

        def find_record_by!(condition)
          activerecord_constant.find_by!(condition)
        end

        def translate(attribute_name)
          @translator.translate_attribute(attribute_name)
        end

        private

        def make_each_attribute_import_value(parent_record_id = nil, initializer: {}, &block)
          values     = initializer.with_indifferent_access
          normalizer = ::ActiveRecord::Bixformer::AssignableAttributesNormalizer.new(plan, self, parent_record_id)

          run_bixformer_callback :import, type: :attribute do
            @attributes.each do |attr|
              next if attr.options[:skip_import]

              attribute_value = begin
                                  run_bixformer_callback :import, on: attr.name do
                                    block.call(attr)
                                  end
                                rescue ::ActiveRecord::Bixformer::AttributeError => e
                                  @errors << e

                                  next
                                end

              # 取り込み時は、 preferred_skip な属性では、有効でない値は取り込まない
              next if ! presence_value?(attribute_value) &&
                      @preferred_skip_attributes.include?(attr.name.to_s)

              values[attr.name] = attribute_value
            end
          end

          # データの検証と正規化
          normalizer.normalize(values).tap do |normalized_values|
            # 結果ハッシュに何かキーがある場合だけ
            if normalized_values.present?
              association_names = @associations.map(&:name)

              # デフォルト値の補完
              @default_values.each do |attribute_name, default_value|
                # 有効な値が既に格納されている場合は補完しない
                next if presence_value?(normalized_values[attribute_name])

                # preferred_skip_attributes で指定されてる場合は補完しない
                next if @preferred_skip_attributes.include?(attribute_name)

                # default_values には association も含まれているため、チェック
                next if association_names.include?(attribute_name)

                normalized_values[attribute_name] = if default_value.is_a?(::Proc)
                                                      default_value.call
                                                    else
                                                      default_value
                                                    end
              end
            end
          end
        end

        def make_each_association_import_value(values, &block)
          return values unless presence_value?(values)

          self_record_id = values[activerecord_constant.primary_key]

          run_bixformer_callback :import, type: :association do
            @associations.each do |association|
              association_value = run_bixformer_callback :import, on: association.name do
                block.call(association, self_record_id)
              end

              if association.errors.present?
                association.errors.each { |e| @errors << e }

                next
              end

              if association_value.is_a?(::Array)
                # has_many な場合は、配列が返ってくるが、空と思われる要素は結果に含めない
                association_value = association_value.reject { |v| ! presence_value?(v) }
              end

              # 取り込み時は、 preferred_skip な関連では、有効でない値は取り込まない
              next if ! presence_value?(association_value) &&
                      @preferred_skip_attributes.include?(association.name.to_s)

              values["#{association.name}_attributes".to_sym] = association_value
            end
          end

          values
        end

        def sortable_value(attribute, value)
          index = @sort_indexes[attribute.name] || @plan.entry_attribute_size

          { index: index, value: value }
        end

        def sort(sortable_values)
          sortable_values_size = sortable_values.size.to_f

          sortable_values.sort_by.with_index(0) do |v, i|
            # Enumerable#sort は安定ではないので、 sort_by を使って、
            # 明示的にユニークで必ず増加する数値を加えることで、同じ index だった場合に
            # 順序が変わらないことを保証する
            v[:index] + i / sortable_values_size
          end.map do |v|
            v[:value]
          end
        end
      end
    end
  end
end
