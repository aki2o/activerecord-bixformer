module SamplePlanFunctions
  def entry
    @options[:entry] || super
  end
  def optional_attributes
    @options[:optional_attributes] || super
  end
  def unique_indexes
    @options[:unique_indexes] || super
  end
  def required_condition
    @options[:required_condition] || super
  end
end

class SampleUserPlan
  include ActiveRecord::Bixformer::Plan
  include SamplePlanFunctions

  bixformer_for :user

  def initialize(options = {})
    @options = options
    super()
  end
end
