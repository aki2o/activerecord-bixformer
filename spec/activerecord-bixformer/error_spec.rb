require 'spec_helper'

describe ActiveRecord::Bixformer::ImportError do
  let(:error) { ActiveRecord::Bixformer::ImportError.new(attribute, value, type) }
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Base.new(model, attribute_name, nil) }
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile }
  let(:plan) { SampleUserPlan.new(entry: SampleEntry.user_all_using_indexed_association) }
  let(:attribute_name) { :account }
  let(:value) { nil }
  let(:type) { :invalid }

  describe "#message" do
    subject { error.message }

    context "on account" do
      it { is_expected.to eq 'AccountName is invalid' }
    end

    context "on joined_at" do
      let(:attribute_name) { :joined_at }

      it { is_expected.to eq 'JoinTime is invalid' }
    end

    context "translation configed" do
      let(:value) { 'hoge' }

      before do
        data = { errors: { messages: { type => 'is invalid (%{value}) data' } } }

        I18n.backend.store_translations(I18n.default_locale, data)
      end

      it { is_expected.to eq 'AccountName is invalid (hoge) data' }
    end
  end
end
