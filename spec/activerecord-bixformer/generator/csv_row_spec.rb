require 'spec_helper'

describe ActiveRecord::Bixformer::Generator::CsvRow do
  let(:generator) { ActiveRecord::Bixformer::Generator::CsvRow.new(SampleCsvModeler.new(modeler_options), data_source) }

  describe "#compile" do
    let(:model) { generator.compile }

    context "all" do
      let(:modeler_options) do
        {
          entry_definitions: SampleEntryDefinition.user_all_using_indexed_association
        }
      end
      let(:data_source) { User.find_by(account: 'sample-taro') }

      it do
        expect(model.name).to eq :user
        expect(model.attribute_map.keys).to eq [:id, :account, :joined_at]
        expect(model.association_map.keys).to eq [:profile, :posts]
        expect(model.association_map[:profile].attribute_map.keys).to eq [:name, :email, :age]
        expect(model.association_map[:posts]).to be_an_instance_of Array
        expect(model.association_map[:posts].size).to eq 3
      end
    end
  end
end
