require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Boolean do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Boolean.new(nil, nil, options) }

  describe "#make_export_value" do
    subject { attribute.make_export_value(value) }

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

  describe "#make_import_value" do
    subject { attribute.make_import_value(value) }
    
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
        
        it { is_expected.to eq nil }
      end
    end

    context "has wrong options" do
      let(:options) { ["Yes", "No"] }

      context "wrong value" do
        let(:value) { "Yes" }
        
        it { is_expected.to eq nil }
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
