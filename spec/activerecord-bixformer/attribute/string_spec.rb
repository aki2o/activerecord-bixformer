require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::String do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::String.new(nil, attribute_name, nil) }
  let(:attribute_name) { :account }
  let(:record) { User.new("#{attribute_name}" => value) }

  describe "#export" do
    subject { attribute.export(record) }

    context "string" do
      let(:value) { "hoge" }

      it { is_expected.to eq "hoge" }
    end

    context "number" do
      let(:value) { 999 }

      it { is_expected.to eq "999" }
    end

    context "boolean" do
      let(:value) { true }

      it { is_expected.to eq "t" }
    end
  end

  describe "#import" do
    subject { attribute.import(value) }
    
    context "string" do
      let(:value) { "hoge" }

      it { is_expected.to eq "hoge" }
    end
    
    context "empty string" do
      let(:value) { "" }

      it { is_expected.to eq nil }
    end
    
    context "space string" do
      let(:value) { "   " }

      it { is_expected.to eq nil }
    end
  end
end
