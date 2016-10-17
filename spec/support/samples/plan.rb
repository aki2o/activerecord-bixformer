module SamplePlanFunctions
  def initialize(options = {})
    @options = options
  end
  def entry
    @options[:entry] || {}
  end
  def preferred_skip_attributes
    @options[:preferred_skip_attributes] || []
  end
  def unique_attributes
    @options[:unique_attributes] || []
  end
  def required_condition
    @options[:required_condition] || {}
  end
  def sort_indexes
    @options[:sort_indexes] || {}
  end
end

class SampleUserPlan
  include ActiveRecord::Bixformer::Plan
  include SamplePlanFunctions

  bixformer_for                       :user
  bixformer_entry                     :entry
  bixformer_preferred_skip_attributes "preferred_skip_attributes"
  bixformer_unique_attributes         :unique_attributes
  bixformer_required_condition  -> {
    @options[:required_condition] || {}
  }
  bixformer_sort_indexes              :sort_indexes
end

class SamplePostPlan
  include ActiveRecord::Bixformer::Plan
  include SamplePlanFunctions

  bixformer_for                       :post
  bixformer_entry                     :entry
end
