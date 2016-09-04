require 'spec_helper'

describe ActiveRecord::Bixformer::Runner::Csv do
  let(:runner) { ActiveRecord::Bixformer::Runner::Csv.new }
  let(:modeler) { SampleCsvModeler.new(modeler_options) }

  let(:modeler_options) do
    {
      entry_definitions: entry_definitions,
      optional_attributes: optional_attributes
    }
  end

  describe "#import" do
    before do
      ENV['TZ'] = 'Asia/Tokyo'

      runner.add_modeler(modeler); runner.import(csv_data, csv_options)
    end

    let(:csv_options) { {} }
    let(:user) { User.find_by(account: 'sample-taro') }

    context "all" do
      let(:entry_definitions) { SampleEntryDefinition.user_all_using_indexed_association }
      let(:optional_attributes) { SampleOptionalAttribute.user_all_default }

      context "new record" do
        let(:csv_data) do
          <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{SampleCsv.user_all_using_indexed_association_line_new.chomp}
EOS
        end

        let(:imported_user) { User.find_by(account: 'import-taro') }

        it do
          expect(runner.errors.size).to eq 0
          expect(imported_user).not_to be_nil
          expect(imported_user.joined_at).to eq Time.new(2016, 9, 1, 15, 31, 21, "+09:00")
          expect(imported_user.profile.name).to eq 'Taro Import'
          expect(imported_user.profile.email).to eq nil
          expect(imported_user.profile.age).to eq 13
          expect(imported_user.posts.size).to eq 2
          expect(imported_user.posts[0].status).to eq :published
          expect(imported_user.posts[1].status).to eq :wip
          expect(imported_user.posts[0].secret).to be_falsey
          expect(imported_user.posts[1].secret).to be_truthy
          expect(imported_user.posts[0].tags.size).to eq 2
          expect(imported_user.posts[1].tags.size).to eq 0
          expect(imported_user.posts[0].tags[0].name).to eq 'Foo'
          expect(imported_user.posts[0].tags[1].name).to eq 'Fuga'
        end
      end
    end
  end
end
