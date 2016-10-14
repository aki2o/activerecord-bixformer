require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Enumerize do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Enumerize.new(model, attribute_name, nil) }
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile.associations.find { |o| o.name == 'posts' } }
  let(:plan) { SampleUserPlan.new(entry: SampleEntry.user_all_using_indexed_association) }
  let(:attribute_name) { :status }
  let(:record) { Post.new("#{attribute_name}" => value) }

  describe "#export" do
    subject { attribute.export(record) }

    context "no value" do
      let(:value) { nil }

      it { is_expected.to eq nil }
    end

    context "invalid value" do
      let(:value) { :hoge }

      it { is_expected.to eq nil }
    end

    context "valid value" do
      let(:value) { :published }

      it { is_expected.to eq 'Now on show' }
    end
  end

  describe "#import" do
    subject { attribute.import(value) }

    context "no value" do
      let(:value) { nil }

      it { is_expected.to eq nil }
    end

    context "empty value" do
      let(:value) { ' ' }

      it { is_expected.to eq nil }
    end

    context "enumerize text value" do
      let(:value) { 'Now on show' }

      it { is_expected.to eq 'published' }
    end

    context "wrong value" do
      let(:value) { 'hoge' }

      it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }
    end
  end
end
