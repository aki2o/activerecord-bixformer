module ActiveRecord
  module Bixformer
    module Modeler
      class Csv < ActiveRecord::Bixformer::Modeler::Base
        def translation_settings
          {
            root_scope: [:activerecord, :attributes],
            extend_scopes: []
          }
        end
      end
    end
  end
end
