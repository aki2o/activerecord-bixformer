require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Date do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Date.new(nil, nil, options) }
  let(:options) { nil }

  describe "#export" do
    subject { attribute.export(value) }
    let(:value) { Date.new(2016, 4, 1) }

    context "no options" do
      it { is_expected.to eq '2016-04-01' }
    end

    context "has options" do
      let(:options) { { format: :ymd } }

      it { is_expected.to eq '2016 04 01' }
    end

    context "nil value" do
      let(:value) { nil }

      it { is_expected.to eq nil }
    end
  end

  describe "#importmethod" do
    subject { attribute.import(value) }

    context "valid value" do
      let(:value) { '2016-04-01' }

      it { is_expected.to eq Date.new(2016, 4, 1) }
    end

    context "option format value" do
      let(:value) { '2016 04 01' }

      context "no options" do
        it { expect{subject}.to raise_error(ArgumentError) }
      end

      context "has options" do
        let(:options) { { format: :ymd } }

        it { is_expected.to eq Date.new(2016, 4, 1) }
      end
    end

    context "empty value" do
      let(:value) { ' ' }

      it { is_expected.to eq nil }
    end

    context "wrong value" do
      let(:value) { 'hoge' }

      context "no options" do
        it { expect{subject}.to raise_error(ArgumentError) }
      end

      context "has options" do
        let(:options) { { format: :ymd } }

        it { expect{subject}.to raise_error(ArgumentError) }
      end
    end
  end
end
