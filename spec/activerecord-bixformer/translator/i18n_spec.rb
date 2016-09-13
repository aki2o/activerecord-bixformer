require 'spec_helper'

describe ActiveRecord::Bixformer::Translator::I18n do
  let(:translator) { ActiveRecord::Bixformer::Translator::I18n.new }
  let(:scope) { :bixformer }
  let(:extend_scopes) { [] }
  let(:model) { ActiveRecord::Bixformer::Model::Base.new(model_name, model_options) }
  let(:model_name) { :user }
  let(:model_options) { nil }
  let(:attribute_arguments_map) { {} }
  let(:model_arguments) { {} }

  before do
    translator.config = {
      scope: scope,
      extend_scopes: extend_scopes
    }
    translator.model = model
    translator.attribute_arguments_map = attribute_arguments_map
    translator.model_arguments = model_arguments
  end

  describe "#translate_attribute" do
    subject { translator.translate_attribute(attribute_name) }
    let(:attribute_name) { :account }

    context "no extend_scopes" do
      it { is_expected.to eq 'AccountName' }

      context "not defined in extend_scopes" do
        let(:attribute_name) { :id }

        it { is_expected.to eq 'UserSystemCode' }
      end
    end

    context "has extend_scopes" do
      let(:extend_scopes) { [:extended] }

      it { is_expected.to eq 'NewAccountName' }

      context "not defined in extend_scopes" do
        let(:attribute_name) { :id }

        it { is_expected.to eq 'UserSystemCode' }
      end
    end

    context "not found key" do
      let(:attribute_name) { :unknown }

      it { expect{subject}.to raise_error(I18n::MissingTranslationData) }
    end
  end
end
