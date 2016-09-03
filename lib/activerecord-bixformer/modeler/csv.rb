module ActiveRecord
  module Bixformer
    module Modeler
      class Csv < ::ActiveRecord::Bixformer::Modeler::Base
        def initialize
          super(:csv)
        end
      end
    end
  end
end
