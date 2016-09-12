require 'spec_helper'

describe ActiveRecord::Bixformer::Generator::ActiveRecord do
  let(:generator) { ActiveRecord::Bixformer::Generator::ActiveRecord.new(SampleCsvModeler.new(modeler_options), data_source) }

  let(:modeler_options) do
    {
      entry_definition: SampleEntryDefinition.user_all_using_indexed_association,
      optional_attributes: optional_attributes,
      unique_indexes: unique_indexes,
      required_condition: required_condition
    }
  end

  let(:optional_attributes) { [] }
  let(:unique_indexes) { [] }
  let(:required_condition) { {} }

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
        expect(model.name).to eq "user"
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

  describe "#generate" do
    subject { generator.generate }

    context "no optional_attributes" do
      let(:expect_value) do
        {
          account: "import-taro",
          joined_at: Time.new(2016, 9, 1, 15, 31, 21, "+09:00"),
          profile_attributes: { name: "Taro Import", email: nil, age: "13" },
          posts_attributes: [
            { content: "Hello!", status: "published", secret: false, tags_attributes: [{name: "Foo"}, {name: "Fuga"}] },
            { content: "Good bye!", status: "wip", secret: true, tags_attributes: [] }
          ]
        }.with_indifferent_access
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
        }.with_indifferent_access
      end

      it { is_expected.to eq expect_value }
    end

    context "exists record" do
      let(:user) { User.find_by(account: 'sample-taro') }
      let(:joined_at) { Time.new(2016, 9, 1, 15, 31, 21, "+09:00") }

      let(:data_source) do
        csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{user.id},sample-taro,#{joined_at.to_s(:ymdhms)},Taro U Sample,"",60,#{user.posts[0].id},Good bye!,Edit disabled,No,Foo,,#{user.posts[1].id},"",Write in Process,No,Bar,,,New Post!,Write in Process,Yes,,
EOS
        CSV.parse(csv_data, headers: true).first
      end

      let(:optional_attributes) { SampleOptionalAttribute.user_all_default }
      let(:unique_indexes) { SampleUniqueIndex.user_all_default }

      let(:expect_value) do
        {
          id: 1,
          account: "sample-taro",
          joined_at: joined_at,
          profile_attributes: { name: "Taro U Sample", email: nil, age: "60", user_id: 1, id: 1 },
          posts_attributes: [
            { id: 1, content: "Good bye!", status: "protected", secret: false, user_id: 1, tags_attributes: [{ name: "Foo", post_id: 1, id: 3 }] },
            { id: 2, content: nil, status: "wip", secret: false, user_id: 1, tags_attributes: [{ name: "Bar", post_id: 2 }] },
            { content: "New Post!", status: "wip", secret: true, user_id: 1 }
          ]
        }.with_indifferent_access
      end

      it { is_expected.to eq expect_value }
    end

    context "has required_condition" do
      let(:group_id) { Group.find_by(name: 'Sample').id }
      let(:required_condition) { { group_id: group_id } }

      let(:expect_value) do
        {
          account: "import-taro",
          group_id: group_id,
          joined_at: Time.new(2016, 9, 1, 15, 31, 21, "+09:00"),
          profile_attributes: { name: "Taro Import", email: nil, age: "13" },
          posts_attributes: [
            { content: "Hello!", status: "published", secret: false, tags_attributes: [{name: "Foo"}, {name: "Fuga"}] },
            { content: "Good bye!", status: "wip", secret: true, tags_attributes: [] }
          ]
        }.with_indifferent_access
      end

      it { is_expected.to eq expect_value }
    end
  end
end
