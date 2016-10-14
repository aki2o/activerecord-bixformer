require 'spec_helper'

describe ActiveRecord::Bixformer::To::Csv do
  let(:bixformer) { ActiveRecord::Bixformer::To::Csv.new(plan) }
  let(:plan) { SampleUserPlan.new(plan_options) }
  let(:plan_options) do
    {
      entry: entry,
      preferred_skip_attributes: preferred_skip_attributes,
      sort_indexes: sort_indexes
    }
  end

  let(:entry) { SampleEntry.user_all_using_indexed_association }
  let(:preferred_skip_attributes) { [] }
  let(:sort_indexes) { {} }

  describe "#csv_title_row" do
    subject { bixformer.csv_title_row }

    context "all" do
      it { is_expected.to eq SampleCsv.user_all_using_indexed_association_title.chomp.split(",") }
    end

    context "sorted" do
      let(:sort_indexes) do
        {
          account: 1,
          profile: {
            email: 1,
          },
          id: 3,
          posts: {
            id: 2,
            content: 2,
            status: 2,
            secret: 2,
            tags: { name: 3 }
          }
        }
      end

      let(:expected_value) do
        [
          "AccountName", "E-mail",
          "PostSystemCode1", "Body1", "Status1", "IsSecret1",
          "PostSystemCode2", "Body2", "Status2", "IsSecret2",
          "PostSystemCode3", "Body3", "Status3", "IsSecret3",
          "UserSystemCode",
          "UserPost1TagName1", "UserPost1TagName2", "UserPost2TagName1", "UserPost2TagName2", "UserPost3TagName1", "UserPost3TagName2",
          "JoinTime", "Name", "Age"
        ]
      end

      it { is_expected.to eq expected_value }
    end
  end

  describe "#csv_body_row" do
    subject { bixformer.csv_body_row(ar) }

    let(:ar) { User.find_by(account: 'sample-taro') }

    context "all" do
      let(:expect_value) do
        [
          "#{ar.id}","sample-taro",ar.joined_at.to_s(:ymdhms),"Taro Sample","",24,"#{ar.posts[0].id}","Hello!","Now on show","No","Foo","Fuga","#{ar.posts[1].id}","","Write in Process","Yes",nil,nil,nil,nil,nil,nil,nil,nil
        ]
      end

      it { is_expected.to eq expect_value }
    end
  end
end
