require 'spec_helper'

describe ActiveRecord::Bixformer::Runner::Csv do
  let(:runner) { ActiveRecord::Bixformer::Runner::Csv.new }
  let(:modeler) { SampleCsvModeler.new(modeler_options) }

  describe "#export" do
    subject { runner.add_modeler(modeler); runner.export(resource, csv_options) }

    context "all" do
      let(:modeler_options) do
        {
          entry_definitions: SampleEntryDefinition.user_all_using_indexed_association
        }
      end
      let(:csv_options) { {} }
      let(:user) { User.find_by(account: 'sample-taro') }
      let(:expect_value) do
        <<EOS
UserSystemCode,AccountName,JoinTime,Name,E-mail,Age,PostSystemCode1,Body1,Status1,IsSecret1,UserPost1TagName1,UserPost1TagName2,PostSystemCode2,Body2,Status2,IsSecret2,UserPost2TagName1,UserPost2TagName2,PostSystemCode3,Body3,Status3,IsSecret3,UserPost3TagName1,UserPost3TagName2
#{user.id},sample-taro,#{user.joined_at.to_s(:ymdhms)},Taro Sample,"",24,#{user.posts[0].id},Hello!,Now on show,No,Foo,Fuga,#{user.posts[1].id},"",Write in Process,Yes,,,,,,,,
EOS
      end

      context "resource is a list of ActiveRecord" do
        let(:resource) { [user] }

        it { is_expected.to eq expect_value }
      end

      context "resource is ActiveRecord::Relation" do
        let(:resource) { User.where(account: 'sample-taro') }

        it { is_expected.to eq expect_value }
      end
    end
  end
end
