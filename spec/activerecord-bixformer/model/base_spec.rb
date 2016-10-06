require 'spec_helper'

describe ActiveRecord::Bixformer::Model::Base do
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile }
  let(:plan) { SampleUserPlan.new(plan_options) }
  let(:plan_options) do
    {
      entry: entry,
      preferred_skip_attributes: preferred_skip_attributes
    }
  end
  let(:entry) { {} }
  let(:preferred_skip_attributes) { [] }

  describe "#should_be_included" do
    subject { model.should_be_included }

    context "no entries" do
      it { is_expected.to eq [] }
    end

    context "user_all_using_indexed_association" do
      let(:entry) { SampleEntry.user_all_using_indexed_association }

      it { is_expected.to eq [:profile, { posts: [:tags] }] }
    end
  end
end
