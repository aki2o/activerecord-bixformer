require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Boolean do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Boolean.new(model, attribute_name, options) }
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile.associations.find { |o| o.name == 'posts' } }
  let(:plan) { SampleUserPlan.new(entry: SampleEntry.user_all_using_indexed_association) }
  let(:attribute_name) { :secret }
  let(:record) { Post.new("#{attribute_name}" => value) }

  describe "}#export" do
    subject { attribute.export(record) }

    context "no options" do
      let(:options) { nil }

      context "true" do
        let(:value) { true }
        
        it { is_expected.to eq "true" }
      end

      context "false" do
        let(:value) { false }
        
        it { is_expected.to eq "false" }
      end
    end

    context "has options" do
      let(:options) { { true: "Yes", false: "No" } }

      context "true" do
        let(:value) { true }
        
        it { is_expected.to eq "Yes" }
      end

      context "false" do
        let(:value) { false }
        
        it { is_expected.to eq "No" }
      end
    end

    context "has wrong options" do
      let(:options) { ["Yes", "No"] }

      context "true" do
        let(:value) { true }
        
        it { is_expected.to eq "true" }
      end

      context "false" do
        let(:value) { false }
        
        it { is_expected.to eq "false" }
      end
    end
  end

  describe "#import" do
    subject { attribute.import(value) }
    
    context "no options" do
      let(:options) { nil }

      context "true" do
        let(:value) { "true" }
        
        it { is_expected.to eq true }
      end

      context "false" do
        let(:value) { "false" }
        
        it { is_expected.to eq false }
      end
    end

    context "has options" do
      let(:options) { { true: "Yes", false: "No" } }

      context "true value" do
        let(:value) { "Yes" }
        
        it { is_expected.to eq true }
      end

      context "false value" do
        let(:value) { "No" }
        
        it { is_expected.to eq false }
      end

      context "other value" do
        let(:value) { "Hoge" }

        it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }

        context "raise falsy" do
          before { options.merge!(raise: false) }

          it { is_expected.to eq nil }
        end
      end
    end

    context "has wrong options" do
      let(:options) { ["Yes", "No"] }

      context "wrong value" do
        let(:value) { "Yes" }
        
        it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }
      end

      context "true" do
        let(:value) { "true" }
        
        it { is_expected.to eq true }
      end

      context "false" do
        let(:value) { "false" }
        
        it { is_expected.to eq false }
      end
    end
  end
end
