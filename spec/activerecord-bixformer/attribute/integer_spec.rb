require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Integer do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Integer.new(model, attribute_name, options) }
  let(:model) { ActiveRecord::Bixformer::Compiler.new(:csv, plan).compile.associations.find { |o| o.name == 'profile' } }
  let(:plan) { SampleUserPlan.new(entry: SampleEntry.user_all_using_indexed_association) }
  let(:attribute_name) { :age }
  let(:record) { UserProfile.new("#{attribute_name}" => value) }
  let(:options) { {} }

  describe "#import" do
    subject { attribute.import(value) }

    context "empty" do
      let(:value) { ' ' }

      it { is_expected.to eq nil }
    end

    context "invalid data" do
      let(:value) { 'hoge' }

      it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }

      context "raise falsy" do
        before { options[:raise] = false }

        it { is_expected.to eq nil }
      end
    end

    context "numeric data" do
      let(:value) { '000123' }

      it { is_expected.to eq 123 }

      context "has greater_than" do
        before { options[:greater_than] = restrict }
        let(:restrict) { 123 }

        it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }

        context "valid data" do
          let(:restrict) { 122 }

          it { is_expected.to eq 123 }
        end

        context "raise falsy" do
          before { options[:raise] = false }

          it { is_expected.to eq nil }
        end
      end

      context "has greater_than_or_equal_to" do
        before { options[:greater_than_or_equal_to] = restrict }
        let(:restrict) { 124 }

        it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }

        context "valid data" do
          let(:restrict) { 123 }

          it { is_expected.to eq 123 }
        end

        context "raise falsy" do
          before { options[:raise] = false }

          it { is_expected.to eq nil }
        end
      end

      context "has less_than" do
        before { options[:less_than] = restrict }
        let(:restrict) { 123 }

        it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }

        context "valid data" do
          let(:restrict) { 124 }

          it { is_expected.to eq 123 }
        end

        context "raise falsy" do
          before { options[:raise] = false }

          it { is_expected.to eq nil }
        end
      end

      context "has less_than_or_equal_to" do
        before { options[:less_than_or_equal_to] = restrict }
        let(:restrict) { 122 }

        it { expect{subject}.to raise_error(ActiveRecord::Bixformer::AttributeError) }

        context "valid data" do
          let(:restrict) { 123 }

          it { is_expected.to eq 123 }
        end

        context "raise falsy" do
          before { options[:raise] = false }

          it { is_expected.to eq nil }
        end
      end
    end
  end
end
