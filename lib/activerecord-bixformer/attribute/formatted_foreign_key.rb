module ActiveRecord
  module Bixformer
    module Attribute
      class FormattedForeignKey < ::ActiveRecord::Bixformer::Attribute::Base
        def initialize(model, attribute_name, options)
          super

          unless @options[:formatter]
            raise ArgumentError.new 'Not configured required options : formatter'
          end

          @options[:parser] ||= if @options[:formatter].is_a?(::String) || @options[:formatter].is_a?(::Symbol)
                                  -> (v) { { @options[:formatter] => v } }
                                end

          unless @options[:parser]
            raise ArgumentError.new 'Not configured required options : parser'
          end
        end

        def export(record)
          association_name = @model.activerecord_constant
                             .reflections.values.find { |r| r.foreign_key == @name }
                             .name

          foreign_record = record.__send__(association_name)

          return nil unless foreign_record

          formatter = @options[:formatter]

          if formatter.is_a?(::Proc)
            formatter.call(foreign_record)
          else
            foreign_record.__send__(formatter)
          end
        end

        def import(value)
          return nil unless value.present?

          parser  = @options[:parser]
          find_by = @options[:find_by]
          scope   = @options[:scope] || :all
          creator = @options[:creator] || :save

          condition = if parser.is_a?(::Proc)
                        parser.call(value)
                      else
                        foreign_constant.__send__(parser, value)
                      end

          return nil unless condition

          scoped_relation = if scope.is_a?(::Proc)
                              scope.call
                            else
                              foreign_constant.__send__(scope)
                            end

          foreign_record = if find_by.is_a?(::Proc)
                             find_by.call(scoped_relation, condition)
                           elsif find_by
                             scoped_relation.__send__(find_by, condition)
                           elsif scoped_relation.respond_to?(:find_by)
                             scoped_relation.find_by(condition)
                           else
                             scoped_relation.find do |r|
                               condition.all? { |k, v| r.__send__(k) == v rescue false }
                             end
                           end

          if ! foreign_record && @options[:create]
            foreign_record = scoped_relation.build(condition)

            if creator.is_a?(::Proc)
              creator.call(foreign_record)
            else
              foreign_record.__send__(creator)
            end
          end

          foreign_record&.__send__(foreign_constant.primary_key)
        end

        def should_be_included
          @model.activerecord_constant.reflections.find { |k, r| r.foreign_key == @name }.first
        end

        private

        def foreign_constant
          @foreign_constant ||= @model.activerecord_constant
                              .reflections.values.find { |r| r.foreign_key == @name }
                              .class_name.constantize
        end
      end
    end
  end
end
