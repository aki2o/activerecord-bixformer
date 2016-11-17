require 'spec_helper'

describe ActiveRecord::Bixformer::PlanAccessor do
  let(:plan) { ActiveRecord::Bixformer::PlanAccessor.new(raw_plan) }
  let(:raw_plan) { SampleUserPlan.new(plan_options) }
  let(:plan_options) { {} }

  let(:model) { parent_model }

  let(:parent_model) do
    ActiveRecord::Bixformer::Model::Csv::Base.new(:user, nil).tap do |o|
      child_models.each { |c| o.add_association(c) }
    end
  end

  let(:child_models) do
    [
      ActiveRecord::Bixformer::Model::Csv::Indexed.new(:posts, size: 1).tap do |o|
        o.add_association(ActiveRecord::Bixformer::Model::Csv::Indexed.new(:tags, size: 1))
      end
    ]
  end

  let(:plan_options) do
    {
      entry: entry,
      preferred_skip_attributes: preferred_skip_attributes,
      required_condition: required_condition
    }
  end

  let(:entry) { SampleEntry.user_all_using_indexed_association }
  let(:preferred_skip_attributes) { SamplePreferredSkipAttribute.user_all_default }
  let(:required_condition) do
    {
      group_id: 123,
      joined_at: current_time,
      posts: {
        secret: true
      }
    }
  end
  let(:current_time) { Time.current }

  describe "#parse_to_type_and_options" do
    subject { plan.parse_to_type_and_options(value) }

    context "with hash" do
      let(:value) { [:indexed, size: 2] }

      it { is_expected.to eq [:indexed, {size: 2}] }
    end
  end

  describe "#entry_attribute_size" do
    subject { plan.entry_attribute_size }
    let(:entry) { SampleEntry.user_all_using_indexed_association }

    it { is_expected.to eq 11 }
  end

  describe "#pickup_value_for" do
    subject { plan.pickup_value_for(model, config_name, default_value) }
    let(:default_value) { nil }

    context "required_condition" do
      let(:config_name) { :required_condition }
      let(:expect_value) { { group_id: 123, joined_at: current_time }.with_indifferent_access }

      it { is_expected.to eq expect_value }

      context "child model" do
        let(:model) { parent_model.associations.first }
        let(:expect_value) { { secret: true }.with_indifferent_access }

        it { is_expected.to eq expect_value }
      end
    end

    context "preferred_skip_attributes" do
      let(:config_name) { :preferred_skip_attributes }

      it { is_expected.to eq ["id"] }

      context "child model" do
        let(:model) { parent_model.associations.first }

        it { is_expected.to eq ["id", "status", "secret", "tags"] }
      end
    end
  end

  describe "#value_of" do
    subject { plan.value_of(config_name) }

    context "preferred_skip_attributes" do
      let(:config_name) { :preferred_skip_attributes }

      it { is_expected.to eq SamplePreferredSkipAttribute.user_all_default }
    end
  end
end
