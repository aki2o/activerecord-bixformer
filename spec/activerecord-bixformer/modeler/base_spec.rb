require 'spec_helper'

describe ActiveRecord::Bixformer::Modeler::Base do
  let(:modeler) { SampleCsvModeler.new(modeler_options) }
  let(:modeler_options) { {} }

  describe "#parse_to_type_and_options" do
    subject { modeler.parse_to_type_and_options(value) }

    context "with hash" do
      let(:value) { [:indexed, size: 2] }

      it { is_expected.to eq [:indexed, {size: 2}] }
    end
  end

  describe "#config_value_for" do
    subject { modeler.config_value_for(model, config_name, default_value) }

    let(:modeler_options) do
      {
        entry_definitions: SampleEntryDefinition.user_all_using_indexed_association,
        optional_attributes: SampleOptionalAttribute.user_all_default
      }
    end

    let(:default_value) { nil }

    context "child model" do
      let(:model) do
        parent_model = ActiveRecord::Bixformer::Model::Csv::Base.new(:user, nil)

        model = ActiveRecord::Bixformer::Model::Csv::Indexed.new_as_association_for_export(parent_model, :posts, size: 1).first

        parent_model.add_association(model)

        model
      end

      context "optional_attributes" do
        let(:config_name) { :optional_attributes }

        it do
          is_expected.to eq [:id, :status, :secret, :tags]

          expect(modeler.optional_attributes).to eq SampleOptionalAttribute.user_all_default
        end
      end
    end
  end
end
