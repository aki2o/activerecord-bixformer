require 'spec_helper'

describe ActiveRecord::Bixformer::PlanAccessor do
  let(:plan) { ActiveRecord::Bixformer::PlanAccessor.new(raw_plan) }
  let(:raw_plan) { SampleUserPlan.new(plan_options) }
  let(:plan_options) { {} }

  describe "#parse_to_type_and_options" do
    subject { plan.parse_to_type_and_options(value) }

    context "with hash" do
      let(:value) { [:indexed, size: 2] }

      it { is_expected.to eq [:indexed, {size: 2}] }
    end
  end

  describe "#entry_attribute_size" do
    subject { plan.entry_attribute_size }
    let(:plan_options) { { entry: SampleEntry.user_all_using_indexed_association } }

    it { is_expected.to eq 11 }
  end

  describe "#pickup_value_for" do
    subject { plan.pickup_value_for(model, config_name, default_value) }

    let(:plan_options) do
      {
        entry: SampleEntry.user_all_using_indexed_association,
        preferred_skip_attributes: SamplePreferredSkipAttribute.user_all_default
      }
    end

    let(:default_value) { nil }

    context "child model" do
      let(:model) do
        parent_model = ActiveRecord::Bixformer::Model::Csv::Base.new(:user, nil)

        model = ActiveRecord::Bixformer::Model::Csv::Indexed.new(:posts, size: 1)

        parent_model.add_association(model)

        model
      end

      context "preferred_skip_attributes" do
        let(:config_name) { :preferred_skip_attributes }

        it do
          is_expected.to eq ["id", "status", "secret", "tags"]

          expect(plan.value_of(:preferred_skip_attributes)).to eq SamplePreferredSkipAttribute.user_all_default
        end
      end
    end
  end
end
