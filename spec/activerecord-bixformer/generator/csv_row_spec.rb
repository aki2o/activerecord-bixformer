require 'spec_helper'

describe ActiveRecord::Bixformer::Generator::CsvRow do
  let(:generator) { ActiveRecord::Bixformer::Generator::CsvRow.new(SampleCsvModeler.new(modeler_options), data_source) }

  let(:modeler_options) do
    {
      entry_definitions: SampleEntryDefinition.user_all_using_indexed_association,
      optional_attributes: optional_attributes
    }
  end

  let(:optional_attributes) { [] }

  let(:data_source) { User.find_by(account: 'sample-taro') }

  before do
    ENV['TZ'] = 'Asia/Tokyo'
  end

  describe "#compile" do
    let(:model) { generator.compile }

    context "all" do
      it do
        expect(model.name).to eq :user
        expect(model.attribute_map.keys).to eq ["id", "account", "joined_at"]
        expect(model.association_map.keys).to eq ["profile", "posts"]
        expect(model.association_map["profile"].attribute_map.keys).to eq ["name", "email", "age"]
        expect(model.association_map["posts"]).to be_an_instance_of Array
        expect(model.association_map["posts"].size).to eq 3
        expect(model.association_map["posts"].first.attribute_map.keys).to eq ["id", "content", "status", "secret"]
        expect(model.association_map["posts"].first.association_map.keys).to eq ["tags"]
        expect(model.association_map["posts"].first.association_map["tags"]).to be_an_instance_of Array
        expect(model.association_map["posts"].first.association_map["tags"].size).to eq 2
        expect(model.association_map["posts"].first.association_map["tags"].first.attribute_map.keys).to eq ["name"]
      end
    end
  end
end
