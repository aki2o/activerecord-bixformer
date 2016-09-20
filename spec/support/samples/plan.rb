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
  def unique_attributes
    @options[:unique_attributes] || []
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
  bixformer_unique_attributes      :unique_attributes
  bixformer_required_condition  -> {
    @options[:required_condition] || {}
  }
end
