require 'spec_helper'

describe ActiveRecord::Bixformer::Generator::CsvRow do
  let(:generator) { ActiveRecord::Bixformer::Generator::CsvRow.new(SampleCsvModeler.new(modeler_options), data_source) }

  describe "#compile" do
    let(:model) { generator.compile }

    context "all" do
      let(:modeler_options) do
        {
          entry_definitions: SampleEntryDefinition.user_all_using_indexed_to_has_many_association
        }
      end
      let(:data_source) { User.find_by(account: 'sample-taro') }

      it do
        expect(model.name).to eq :user
      end
    end
  end
end
