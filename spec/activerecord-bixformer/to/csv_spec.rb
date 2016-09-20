require 'spec_helper'

describe ActiveRecord::Bixformer::To::Csv do
  let(:bixformer) { ActiveRecord::Bixformer::To::Csv.new(plan) }
  let(:plan) { SampleUserPlan.new(plan_options) }
  let(:plan_options) do
    {
      entry: entry,
      preferred_skip_attributes: preferred_skip_attributes
    }
  end

  let(:entry) { SampleEntry.user_all_using_indexed_association }
  let(:preferred_skip_attributes) { [] }

  describe "#csv_title_row" do
    subject { bixformer.csv_title_row }

    context "all" do
      it { is_expected.to eq SampleCsv.user_all_using_indexed_association_title.chomp.split(",") }
    end
  end

  describe "#csv_body_row" do
    subject { bixformer.csv_body_row(ar) }

    let(:ar) { User.find_by(account: 'sample-taro') }

    context "all" do
      let(:expect_value) do
        [
          "#{ar.id}","sample-taro",ar.joined_at.to_s(:ymdhms),"Taro Sample","","24","#{ar.posts[0].id}","Hello!","Now on show","No","Foo","Fuga","#{ar.posts[1].id}","","Write in Process","Yes",nil,nil,nil,nil,nil,nil,nil,nil
        ]
      end

      it { is_expected.to eq expect_value }
    end
  end
end
