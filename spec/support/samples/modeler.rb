module SampleModelerFunctions
  def model_name
    @options[:model_name] || :user
  end
  def entry_definition
    @options[:entry_definition] || super
  end
  def optional_attributes
    @options[:optional_attributes] || super
  end
  def unique_indexes
    @options[:unique_indexes] || super
  end
end

class SampleCsvModeler < ActiveRecord::Bixformer::Modeler::Csv
  include SampleModelerFunctions

  def initialize(options = {})
    @options = options
    super()
  end
end
