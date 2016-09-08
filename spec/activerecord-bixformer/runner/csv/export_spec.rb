require 'spec_helper'

describe ActiveRecord::Bixformer::Runner::Csv do
  let(:runner) { ActiveRecord::Bixformer::Runner::Csv.new }
  let(:modeler) { SampleCsvModeler.new(modeler_options) }

  let(:modeler_options) do
    {
      entry_definitions: entry_definitions,
    }
  end

  describe "#export" do
    subject { runner.add_modeler(modeler); runner.export(resource, csv_options) }

    let(:csv_options) { {} }

    context "all" do
      let(:entry_definitions) { SampleEntryDefinition.user_all_using_indexed_association }
      let(:user) { User.find_by(account: 'sample-taro') }
      let(:expect_value) do
        <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
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
