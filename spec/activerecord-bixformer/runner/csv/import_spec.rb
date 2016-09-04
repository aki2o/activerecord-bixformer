require 'spec_helper'

describe ActiveRecord::Bixformer::Runner::Csv do
  let(:runner) { ActiveRecord::Bixformer::Runner::Csv.new }
  let(:modeler) { SampleCsvModeler.new(modeler_options) }

  describe "#import" do
    before do
      ENV['TZ'] = 'Asia/Tokyo'

      runner.add_modeler(modeler); runner.import(csv_data, csv_options)
    end

    context "all" do
      let(:modeler_options) do
        {
          entry_definitions: SampleEntryDefinition.user_all_using_indexed_association,
          optional_attributes: optional_attributes
        }
      end
      let(:csv_options) { {} }

      context "one record" do
        let(:user) { User.find_by(account: 'sample-taro') }
        # let(:optional_attributes) { SampleOptionalAttribute.user_all_default }
        let(:optional_attributes) { [] }
        let(:csv_data) do
          <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{SampleCsv.user_all_using_indexed_association_line_new.chomp}
EOS
        end

        it do
          expect(runner.errors.size).to be > 0
          expect(runner.errors).to eq []
          # expect(User.all.size).to eq 1
          # expect(User.all.first.account).to eq 'y-taro'
          # expect(User.all.first.joined_at).to eq Time.new(2016, 9, 1, 15, 31, 21, "+09:00")
          # expect(User.all.first.profile.name).to eq 'Taro Yamada'
          # expect(User.all.first.profile.age).to eq 24
          # expect(User.all.first.posts.size).to eq 2
          # expect(User.all.first.posts[0].status).to eq :wip
          # expect(User.all.first.posts[1].status).to eq :published
          # expect(User.all.first.posts[0].secret).to be_truthy
          # expect(User.all.first.posts[1].secret).to be_falsey
          # expect(User.all.first.posts[0].tags.size).to eq 2
          # expect(User.all.first.posts[1].tags.size).to eq 0
        end
      end
    end
  end
end
