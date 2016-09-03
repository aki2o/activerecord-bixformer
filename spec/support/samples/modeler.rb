module SampleModelerFunctions
  def model_name
    @options[:model_name] || :user
  end
  def entry_definitions
    @options[:entry_definitions] || super
  end
  def optional_attributes
    @options[:optional_attributes] || super
  end
end

class SampleCsvModeler < ActiveRecord::Bixformer::Modeler::Csv
  include SampleModelerFunctions

  def initialize(options = {})
    @options = options
    super()
  end
end
