require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Booletania do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Booletania.new(model, attribute_name, options) }
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile.associations.find { |o| o.name == 'posts' } }
  let(:plan) { SampleUserPlan.new(entry: SampleEntry.user_all_using_indexed_association) }
  let(:attribute_name) { :secret }
  let(:record) { Post.new("#{attribute_name}" => value) }
  let(:options) { nil }

  describe "#export" do
    subject { attribute.export(record) }

    context "no value" do
      let(:value) { nil }

      it { is_expected.to eq nil }
    end

    context "other value" do
      let(:value) { :hoge }

      it { is_expected.to eq 'Yes' }
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

  describe "#import" do
    subject { attribute.import(value) }

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

      it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }

      context "raise falsy" do
        let(:options) { { raise: false } }

        it { is_expected.to eq nil }
      end
    end
  end
end
