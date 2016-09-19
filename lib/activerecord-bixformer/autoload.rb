module ActiveRecord
  module Bixformer
    autoload :AssignableAttributesNormalizer, 'activerecord-bixformer/assignable_attributes_normalizer'
    autoload :Compiler,                       'activerecord-bixformer/compiler'
    autoload :ImportValueValidatable,         'activerecord-bixformer/import_value_validatable'
    autoload :Plan,                           'activerecord-bixformer/plan'
    autoload :PlanAccessor,                   'activerecord-bixformer/plan_accessor'

    module Attribute
      autoload :Base,       'activerecord-bixformer/attribute/base'
      autoload :Boolean,    'activerecord-bixformer/attribute/boolean'
      autoload :Booletania, 'activerecord-bixformer/attribute/booletania'
      autoload :Date,       'activerecord-bixformer/attribute/date'
      autoload :Enumerize,  'activerecord-bixformer/attribute/enumerize'
      autoload :Override,   'activerecord-bixformer/attribute/override'
      autoload :Time,       'activerecord-bixformer/attribute/time'
    end

    module Model
      autoload :Base, 'activerecord-bixformer/model/base'
    end

    module Translator
      autoload :I18n, 'activerecord-bixformer/translator/i18n'
    end
  end
end