module ActiveRecord
  module Bixformer
    autoload :AssignableAttributesNormalizer, 'activerecord-bixformer/assignable_attributes_normalizer'
    autoload :Compiler,                       'activerecord-bixformer/compiler'
    autoload :ImportValueValidatable,         'activerecord-bixformer/import_value_validatable'
    autoload :Plan,                           'activerecord-bixformer/plan'
    autoload :PlanAccessor,                   'activerecord-bixformer/plan_accessor'
    autoload :ModelCallback,                  'activerecord-bixformer/model_callback'
    autoload :ImportError,                    'activerecord-bixformer/error'
    autoload :DataInvalid,                    'activerecord-bixformer/error'

    module Attribute
      autoload :Base,                'activerecord-bixformer/attribute/base'
      autoload :Boolean,             'activerecord-bixformer/attribute/boolean'
      autoload :Booletania,          'activerecord-bixformer/attribute/booletania'
      autoload :Date,                'activerecord-bixformer/attribute/date'
      autoload :Enumerize,           'activerecord-bixformer/attribute/enumerize'
      autoload :FormattedForeignKey, 'activerecord-bixformer/attribute/formatted_foreign_key'
      autoload :Override,            'activerecord-bixformer/attribute/override'
      autoload :String,              'activerecord-bixformer/attribute/string'
      autoload :Time,                'activerecord-bixformer/attribute/time'
    end

    module Model
      autoload :Base, 'activerecord-bixformer/model/base'
    end

    module Translator
      autoload :I18n, 'activerecord-bixformer/translator/i18n'
    end
  end
end
