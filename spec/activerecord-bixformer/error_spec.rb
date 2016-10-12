require 'spec_helper'

describe ActiveRecord::Bixformer::AttributeError do
  let(:error) { ActiveRecord::Bixformer::AttributeError.new(attribute, value, type) }
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Base.new(model, attribute_name, nil) }
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile }
  let(:plan) { SampleUserPlan.new(entry: SampleEntry.user_all_using_indexed_association) }
  let(:attribute_name) { :account }
  let(:value) { nil }
  let(:type) { :invalid }

  describe "#message" do
    subject { error.message }
    let(:value) { 'hoge' }

    context "translation not configured" do
      it { is_expected.to eq 'is invalid' }
    end

    context "translation configured" do
      let(:translations) do
        { errors: { messages: { type => 'is invalid (%{value}) data' } } }
      end

      before { I18n.backend.store_translations(I18n.default_locale, translations) }

      it { is_expected.to eq 'is invalid (hoge) data' }
    end
  end

  describe "#full_message" do
    subject { error.full_message }

    context "on account" do
      it { is_expected.to eq "AccountName #{error.message}" }
    end

    context "on joined_at" do
      let(:attribute_name) { :joined_at }

      it { is_expected.to eq "JoinTime #{error.message}" }
    end
  end
end

describe ActiveRecord::Bixformer::Errors do
  let(:errors) { ActiveRecord::Bixformer::Errors.new }
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile }
  let(:plan) { SampleUserPlan.new(entry: SampleEntry.user_all_using_indexed_association) }

  describe "#messages" do
    subject { errors.messages }

    context "empty" do
      it { is_expected.to eq [] }
    end

    context "not empty" do
      let(:attribute) { ActiveRecord::Bixformer::Attribute::Base.new(model, :account, nil) }
      let(:error) { ActiveRecord::Bixformer::AttributeError.new(attribute, nil, :invalid) }

      before { errors << error }

      it { is_expected.to eq [error.message] }
    end
  end

  describe "#full_messages" do
    subject { errors.full_messages }

    context "empty" do
      it { is_expected.to eq [] }
    end

    context "not empty" do
      let(:attribute) { ActiveRecord::Bixformer::Attribute::Base.new(model, :account, nil) }
      let(:error) { ActiveRecord::Bixformer::AttributeError.new(attribute, nil, :invalid) }

      before { errors << error }

      it { is_expected.to eq [error.full_message] }
    end
  end
end
