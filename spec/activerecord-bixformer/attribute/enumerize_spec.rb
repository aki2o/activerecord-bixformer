require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Enumerize do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Enumerize.new(model, attribute_name, nil) }
  let(:model) { ActiveRecord::Bixformer::Model::Base.new(:post, nil) }
  let(:attribute_name) { :status }

  describe "#make_export_value" do
    subject { attribute.make_export_value('') }

    context "no data_source" do

      it { is_expected.to eq nil }
    end

    context "has data_source" do
      before do
        model.data_source = Post.new(user_id: 1, status: status)
      end

      context "no value" do
        let(:status) { nil }

        it { is_expected.to eq nil }
      end

      context "has value" do
        let(:status) { :published }

        it { is_expected.to eq 'Now on show' }
      end
    end
  end

  describe "#make_import_value" do
    subject { attribute.make_import_value(value) }

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

      it { expect{subject}.to raise_error(ArgumentError) }
    end
  end
end
