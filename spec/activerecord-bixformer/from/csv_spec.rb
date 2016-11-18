require 'spec_helper'

describe ActiveRecord::Bixformer::From::Csv do
  let(:bixformer) { ActiveRecord::Bixformer::From::Csv.new(plan) }
  let(:plan) { SampleUserPlan.new(plan_options) }
  let(:plan_options) do
    {
      entry: entry,
      preferred_skip_attributes: preferred_skip_attributes,
      unique_attributes: unique_attributes,
      required_condition: required_condition
    }
  end

  let(:entry) { SampleEntry.user_all_using_indexed_association }
  let(:preferred_skip_attributes) { [] }
  let(:unique_attributes) { [] }
  let(:required_condition) { {} }

  before do
    ENV['TZ'] = 'Asia/Tokyo'
  end

  describe "#verify_csv_titles" do
    subject { bixformer.verify_csv_titles(csv_row) }

    let(:csv_row) do
      csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
EOS
      CSV.parse(csv_data).first
    end

    context "includes all titles" do
      it { is_expected.to be_truthy }
    end

    context "remove first title" do
      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp.sub(/^[^,]+,/, '')}
EOS
        CSV.parse(csv_data).first
      end

      it { is_expected.to be_falsy }
    end

    context "remove last title as indexed" do
      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp.sub(/,[^,]+$/, '')}
EOS
        CSV.parse(csv_data).first
      end

      it { is_expected.to be_truthy }
    end

    context "mapped" do
      let(:plan) { SamplePostPlan.new(entry: SampleEntry.post_using_mapped_tag) }

      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.post_using_mapped_tag_title.chomp}
EOS

        CSV.parse(csv_data).first
      end

      it { is_expected.to be_truthy }

      context "remove last tags name" do
        let(:csv_row) do
          csv_data = <<EOS
#{SampleCsv.post_using_mapped_tag_title.chomp.sub(/,[^,]+$/, '')}
EOS

          CSV.parse(csv_data).first
        end

        it { is_expected.to be_falsy }
      end
    end
  end

  describe "#assignable_attributes" do
    subject { bixformer.assignable_attributes(csv_row) }

    let(:csv_row) do
      csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{SampleCsv.user_all_using_indexed_association_line_new.chomp}
EOS
      CSV.parse(csv_data, headers: true).first
    end

    context "no preferred_skip_attributes" do
      let(:expect_value) do
        {
          account: "import-taro",
          joined_at: Time.new(2016, 9, 1, 15, 31, 21, "+09:00"),
          profile_attributes: { name: "Taro Import", email: nil, age: 13 },
          posts_attributes: [
            { content: "Hello!", status: "published", secret: false, tags_attributes: [{name: "Foo"}, {name: "Fuga"}] },
            { content: "Good bye!", status: "wip", secret: true, tags_attributes: [] }
          ]
        }.with_indifferent_access
      end

      it { is_expected.to eq expect_value }
    end

    context "has preferred_skip_attributes" do
      let(:preferred_skip_attributes) { SamplePreferredSkipAttribute.user_all_default }

      let(:expect_value) do
        {
          account: "import-taro",
          joined_at: Time.new(2016, 9, 1, 15, 31, 21, "+09:00"),
          profile_attributes: { name: "Taro Import", email: nil, age: 13 },
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

      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{user.id},sample-taro,#{joined_at.to_s(:ymdhms)},Taro U Sample,"",60,#{user.posts[0].id},Good bye!,Edit disabled,No,Foo,,#{user.posts[1].id},"",Write in Process,No,Bar,,,New Post!,Write in Process,Yes,,
EOS
        CSV.parse(csv_data, headers: true).first
      end

      let(:preferred_skip_attributes) { SamplePreferredSkipAttribute.user_all_default }
      let(:unique_attributes) { SampleUniqueAttribute.user_all_default }

      let(:expect_value) do
        {
          id: 1,
          account: "sample-taro",
          joined_at: joined_at,
          profile_attributes: { name: "Taro U Sample", email: nil, age: 60, user_id: 1, id: 1 },
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
          profile_attributes: { name: "Taro Import", email: nil, age: 13 },
          posts_attributes: [
            { content: "Hello!", status: "published", secret: false, tags_attributes: [{name: "Foo"}, {name: "Fuga"}] },
            { content: "Good bye!", status: "wip", secret: true, tags_attributes: [] }
          ]
        }.with_indifferent_access
      end

      it { is_expected.to eq expect_value }
    end

    context "invalid data included" do
      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{SampleCsv.user_all_using_indexed_association_line_new.chomp.gsub(/[0-9]/, 'a').gsub(/No/, 'NG')}
EOS
        CSV.parse(csv_data, headers: true).first
      end

      it 'abort' do
        expect{subject}.to raise_error(ActiveRecord::Bixformer::ImportError)
      end

      it "has original error" do
        error = begin
                  subject
                rescue => e
                  e
                end

        expect(error.model.errors).to be_an_instance_of ActiveRecord::Bixformer::Errors
        expect(error.model.errors.full_messages).to be_an_instance_of Array
        expect(error.model.errors.full_messages.size).to be > 0
      end
    end

    context "invalid id child record" do
      let(:preferred_skip_attributes) { SamplePreferredSkipAttribute.user_all_default }

      let(:user) { User.find_or_create_by!(account: 'invalid-id-child', joined_at: Time.current) }
      let(:post_id) { user.posts.find_or_create_by!(content: 'Wrong user!', status: :published).id }
      let(:other_user) { User.find_by(account: 'sample-taro') }

      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{other_user.id},sample-taro,#{other_user.joined_at.to_s(:ymdhms)},Taro Invalid,"",60,#{post_id},Wrong user!,Edit disabled,No,Foo,,,,,,,,,,,,,
EOS
        CSV.parse(csv_data, headers: true).first
      end

      it 'abort' do
        expect{subject}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "invalid id root record" do
      let(:preferred_skip_attributes) { SamplePreferredSkipAttribute.user_all_default }

      let(:group) { Group.find_or_create_by!(name: 'NewGroup') }
      let(:other_group) { Group.find_or_create_by!(name: 'OtherGroup') }
      let(:account) { 'invalid-id-root' }
      let(:joined_at) { Time.new(2016, 9, 1, 15, 31, 21, "+09:00") }

      let(:user) { User.find_or_create_by!(group: other_group, account: account, joined_at: joined_at) }

      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{user.id},invalid-id-root,#{joined_at.to_s(:ymdhms)},Taro in wrong group,"",60,,belongs to wrong group!,Edit disabled,No,Foo,,,,,,,,,,,,,
EOS

        CSV.parse(csv_data, headers: true).first
      end

      context "has not required condition" do
        let(:expect_value) do
          user_id = User.find_by(account: account).id

          {
            id: user_id,
            account: account,
            joined_at: joined_at,
            profile_attributes: { name: "Taro in wrong group", email: nil, age: 60, user_id: user_id },
            posts_attributes: [
              { content: "belongs to wrong group!", status: "protected", secret: false, user_id: user_id, tags_attributes: [{name: "Foo"}] }
            ]
          }.with_indifferent_access
        end

        it "succeed normally" do
          is_expected.to eq expect_value
        end
      end

      context "has required condition" do
        let(:required_condition) { { group_id: group.id } }

        before do
          User.find_by(account: account)&.destroy!
        end

        it "abort" do
          expect{subject}.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "mapped" do
      let(:plan) { SamplePostPlan.new(entry: SampleEntry.post_using_mapped_tag) }

      let(:csv_row) do
        csv_data = <<EOS
#{SampleCsv.post_using_mapped_tag_title.chomp}
,It's new post!,Write in Process,first tag,,last tag
EOS

        CSV.parse(csv_data, headers: true).first
      end

      let(:expect_value) do
        {
          content: "It's new post!",
          status: "wip",
          tags_attributes: [
            { name: "Hoge", memo: "first tag" },
            { name: "Fuga", memo: nil },
            { name: "Foo", memo: "last tag" }
          ]
        }.with_indifferent_access
      end

      it { is_expected.to eq expect_value }
    end

    context "skip_import" do
      let(:entry) do
        SampleEntry.user_all_using_indexed_association.tap do |o|
          o[:attributes][:account] = [:string, skip_import: true]
        end
      end

      let(:expect_value) do
        {
          joined_at: Time.new(2016, 9, 1, 15, 31, 21, "+09:00"),
          profile_attributes: { name: "Taro Import", email: nil, age: 13 },
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
