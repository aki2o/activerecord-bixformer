module ActiveRecord
  module Bixformer
    module Attribute
      class FormattedForeignKey < ::ActiveRecord::Bixformer::Attribute::Base
        def initialize(model, attribute_name, options)
          super

          unless @options[:by]
            raise ArgumentError.new 'Not configured required options : by'
          end

          @options[:find_by] ||= if @options[:by].is_a?(::String) || @options[:by].is_a?(::Symbol)
                                   @options[:by]
                                 end

          unless @options[:find_by]
            raise ArgumentError.new 'Not configured required options : find_by'
          end
        end

        def export(record)
          association_name = @model.activerecord_constant
                             .reflections.values.find { |r| r.foreign_key == @name }
                             .name

          foreign_record = record.__send__(association_name)

          return nil unless foreign_record

          formatter = @options[:by]

          if formatter.is_a?(::Proc)
            self.instance_exec foreign_record, &formatter
          else
            foreign_record.__send__(formatter)
          end
        end

        def import(value)
          return nil unless value.present?

          find_by = @options[:find_by]
          scope   = @options[:scope] || :all
          finder  = @options[:finder] || :find_by
          creator = @options[:creator] || :save

          condition = if find_by.is_a?(::Proc)
                        self.instance_exec value, &find_by
                      else
                        { find_by => value }
                      end

          foreign_record = if scope.is_a?(::Proc)
                             self.instance_exec(&scope).__send__(finder, condition)
                           else
                             foreign_constant.__send__(scope).__send__(finder, condition)
                           end

          if ! foreign_record && @options[:create]
            foreign_record = if scope.is_a?(::Proc)
                               self.instance_exec(&scope).build(condition)
                             else
                               foreign_constant.__send__(scope).build(condition)
                             end

            if creator.is_a?(::Proc)
              self.instance_exec foreign_record, &creator
            else
              foreign_record.__send__(creator)
            end
          end

          foreign_record&.__send__(foreign_constant.primary_key)
        end

        private

        def foreign_constant
          @foreign_constant ||= @model.activerecord_constant
                              .reflections.values.find { |r| r.foreign_key == @name }
                              .table_name.classify.constantize
        end
      end
    end
  end
end
