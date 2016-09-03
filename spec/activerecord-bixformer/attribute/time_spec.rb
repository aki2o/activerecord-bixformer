require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Time do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Time.new(nil, nil, options) }
  let(:options) { nil }

  describe "#make_export_value" do
    subject { attribute.make_export_value(value) }
    let(:value) { Time.new(2016, 9, 1, 15, 31, 21, "+00:00") }

    context "no options" do
      it { is_expected.to eq '2016-09-01 15:31:21 +0000' }
    end

    context "has options" do
      let(:options) { { format: :ymdhms } }

      it { is_expected.to eq '2016 09 01 (15:31:21)' }
    end

    context "nil value" do
      let(:value) { nil }

      it { is_expected.to eq nil }
    end
  end

  describe "#make_import_valuemethod" do
    subject { attribute.make_import_value(value) }

    context "valid value" do
      let(:value) { '2016-09-01 15:31:21 +00:00' }

      it { is_expected.to eq Time.new(2016, 9, 1, 15, 31, 21, "+00:00") }
    end

    context "valid value without timezone" do
      let(:value) { '2016-09-01 15:31:21' }

      before { ENV['TZ'] = 'US/Central' }

      it { is_expected.to eq Time.new(2016, 9, 1, 15, 31, 21, "-05:00") }
    end

    context "option format value" do
      let(:value) { '2016 09 01 (15:31:21)' }

      before { ENV['TZ'] = 'US/Central' }

      context "no options" do
        it { expect{subject}.to raise_error(ArgumentError) }
      end

      context "has options" do
        let(:options) { { format: :ymdhms } }

        it { is_expected.to eq Time.new(2016, 9, 1, 15, 31, 21, "-05:00") }
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
        let(:options) { { format: :ymdhms } }

        it { expect{subject}.to raise_error(ArgumentError) }
      end
    end
  end
end