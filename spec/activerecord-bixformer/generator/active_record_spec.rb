require 'spec_helper'

describe ActiveRecord::Bixformer::Generator::ActiveRecord do
  let(:generator) { ActiveRecord::Bixformer::Generator::ActiveRecord.new(SampleCsvModeler.new(modeler_options), data_source) }

  let(:modeler_options) do
    {
      entry_definitions: SampleEntryDefinition.user_all_using_indexed_association,
      optional_attributes: optional_attributes
    }
  end

  let(:optional_attributes) { [] }

  let(:data_source) do
    csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{SampleCsv.user_all_using_indexed_association_line_new.chomp}
EOS
    CSV.parse(csv_data, headers: true).first
  end

  before do
    ENV['TZ'] = 'Asia/Tokyo'
  end

  describe "#compile" do
    let(:model) { generator.compile }

    context "all" do
      it do
        expect(model.name).to eq :user
        expect(model.attribute_map.keys).to eq [:id, :account, :joined_at]
        expect(model.association_map.keys).to eq [:profile, :posts]
        expect(model.association_map[:profile].attribute_map.keys).to eq [:name, :email, :age]
        expect(model.association_map[:posts]).to be_an_instance_of Array
        expect(model.association_map[:posts].size).to eq 3
        expect(model.association_map[:posts].first.attribute_map.keys).to eq [:id, :content, :status, :secret]
        expect(model.association_map[:posts].first.association_map.keys).to eq [:tags]
        expect(model.association_map[:posts].first.association_map[:tags]).to be_an_instance_of Array
        expect(model.association_map[:posts].first.association_map[:tags].size).to eq 2
        expect(model.association_map[:posts].first.association_map[:tags].first.attribute_map.keys).to eq [:name]
      end
    end
  end

  describe "#generate" do
    subject { generator.generate }

    context "no optional_attributes" do
      let(:expect_value) do
        {
          id: nil,
          account: "import-taro",
          joined_at: Time.new(2016, 9, 1, 15, 31, 21, "+09:00"),
          profile_attributes: { name: "Taro Import", email: nil, age: "13" },
          posts_attributes: [
            { id: nil, content: "Hello!", status: "published", secret: false,
              tags_attributes: [{name: "Foo"}, {name: "Fuga"}] },
            { id: nil, content: "Good bye!", status: "wip", secret: true,
              tags_attributes: [] }
          ]
        }
      end

      it { is_expected.to eq expect_value }
    end

    context "has optional_attributes" do
      let(:optional_attributes) { SampleOptionalAttribute.user_all_default }

      let(:expect_value) do
        {
          account: "import-taro",
          joined_at: Time.new(2016, 9, 1, 15, 31, 21, "+09:00"),
          profile_attributes: { name: "Taro Import", email: nil, age: "13" },
          posts_attributes: [
            { content: "Hello!", status: "published", secret: false, tags_attributes: [{name: "Foo"}, {name: "Fuga"}] },
            { content: "Good bye!", status: "wip", secret: true }
          ]
        }
      end

      it { is_expected.to eq expect_value }
    end
  end
end
