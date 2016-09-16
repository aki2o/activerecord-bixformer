require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Booletania do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Booletania.new(model, attribute_name, nil) }
  let(:model) { ActiveRecord::Bixformer::Model::Base.new(:post, nil) }
  let(:attribute_name) { :secret }

  describe "#make_export_value" do
    subject { attribute.make_export_value(value) }

    context "no value" do
      let(:value) { nil }

      it { is_expected.to eq nil }
    end

    context "invalid value" do
      let(:value) { :hoge }

      it { is_expected.to eq nil }
    end

    context "true value" do
      let(:value) { true }

      it { is_expected.to eq 'Yes' }
    end

    context "false value" do
      let(:value) { false }

      it { is_expected.to eq 'No' }
    end
  end

  describe "#make_import_value" do
    subject { attribute.make_import_value(value) }

    context "no value" do
      let(:value) { nil }

      it { is_expected.to eq nil }
    end

    context "true value" do
      let(:value) { 'Yes' }

      it { is_expected.to eq true }
    end

    context "false value" do
      let(:value) { 'No' }

      it { is_expected.to eq false }
    end

    context "wrong value" do
      let(:value) { 'true' }

      it { is_expected.to eq nil }
    end
  end
end
