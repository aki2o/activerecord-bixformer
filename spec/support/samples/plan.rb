module SamplePlanFunctions
  def initialize(options = {})
    @options = options
  end
  def entry
    @options[:entry] || {}
  end
  def optional_attributes
    @options[:optional_attributes] || []
  end
  def unique_indexes
    @options[:unique_indexes] || []
  end
  def required_condition
    @options[:required_condition] || {}
  end
end

class SampleUserPlan
  include ActiveRecord::Bixformer::Plan
  include SamplePlanFunctions

  bixformer_for                 :user
  bixformer_entry               :entry
  bixformer_optional_attributes "optional_attributes"
  bixformer_unique_indexes      :unique_indexes
  bixformer_required_condition  :required_condition
end
