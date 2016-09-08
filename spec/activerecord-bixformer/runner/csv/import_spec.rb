require 'spec_helper'

describe ActiveRecord::Bixformer::Runner::Csv do
  let(:runner) { ActiveRecord::Bixformer::Runner::Csv.new }
  let(:modeler) { SampleCsvModeler.new(modeler_options) }

  let(:modeler_options) do
    {
      entry_definitions: entry_definitions,
      optional_attributes: optional_attributes,
      unique_indexes: unique_indexes
    }
  end

  describe "#import" do
    before do
      ENV['TZ'] = 'Asia/Tokyo'

      runner.add_modeler(modeler)
      runner.import(csv_data, csv_options)
    end

    let(:csv_options) { {} }

    context "all" do
      let(:entry_definitions) { SampleEntryDefinition.user_all_using_indexed_association }
      let(:optional_attributes) { SampleOptionalAttribute.user_all_default }
      let(:unique_indexes) { SampleUniqueIndex.user_all_default }

      context "new record" do
        let(:csv_data) do
          <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{SampleCsv.user_all_using_indexed_association_line_new.chomp}
EOS
        end

        it do
          imported_user = User.find_by(account: 'import-taro')

          expect(runner.errors).to eq []
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

      context "update record" do
        let(:account) { 'renew-taro' }
        let(:joined_at) { Time.new(2016, 9, 2, 15, 31, 21, "+09:00") }

        let(:csv_data) do
          user = User.new(account: account, joined_at: Time.current).tap do |u|
            u.save!

            u.build_profile(name: 'Taro Already', age: 24).save!

            u.posts.build(status: :published, secret: false, content: 'Reborn!').save!
            u.posts.build(status: :wip, secret: true).save!

            u.posts.first.tags.build(name: 'Fuga').save!
            u.posts.first.tags.build(name: 'Foo').save!
            u.posts.first.tags.build(name: 'Bar').save!
          end

        <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
#{user.id},renew-taro,#{joined_at.to_s(:ymdhms)},Taro Changed,"",60,#{user.posts[0].id},Good bye!,Edit disabled,No,Foo,,#{user.posts[1].id},"",Write in Process,No,Bar,,,New Post!,Write in Process,Yes,,
EOS
        end

        it do
          imported_user = User.find_by(account: account)

          expect(runner.errors).to eq []
          expect(imported_user).not_to be_nil

          expect(imported_user.joined_at).to eq joined_at          # changed
          expect(imported_user.profile.name).to eq 'Taro Changed'  # changed

          expect(imported_user.posts.size).to eq 3                 # appended

          expect(imported_user.posts[0].content).to eq 'Good bye!' # changed
          expect(imported_user.posts[0].status).to eq :protected   # changed
          expect(imported_user.posts[0].tags.size).to eq 3         # not deleted and appended

          expect(imported_user.posts[1].secret).to be_falsey       # changed
          expect(imported_user.posts[1].tags.size).to eq 1         # appended
          expect(imported_user.posts[1].tags[0].name).to eq 'Bar'  # appended

          expect(imported_user.posts[2].content).to eq 'New Post!' # appended
          expect(imported_user.posts[2].status).to eq :wip         # appended
          expect(imported_user.posts[2].secret).to be_truthy       # appended
          expect(imported_user.posts[2].tags.size).to eq 0         # not appended
        end
      end

      context "destroy record" do
        let(:entry_definitions) do
          SampleEntryDefinition.user_all_using_indexed_association.dup.tap do |o|
            o[:attributes][:_destroy] = :boolean
          end
        end

        let(:account) { 'unused-taro' }

        let(:csv_data) do
          user = User.new(account: account, joined_at: Time.current).tap do |u|
            u.save!

            u.build_profile(name: 'Taro Unavailable', age: 24).save!

            u.posts.build(status: :published, secret: false, content: 'See you!').save!
            u.posts.build(status: :wip, secret: true).save!

            u.posts.first.tags.build(name: 'Tag1').save!
            u.posts.first.tags.build(name: 'Tag2').save!
            u.posts.first.tags.build(name: 'Tag3').save!
          end

          <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp},UserDeletion
#{user.id},#{account},2016 09 01 (15:31:21),Taro Import,"",13,,Hello!,Now on show,No,Foo,Fuga,,Good bye!,Write in Process,Yes,,,,,,,,,true
EOS
        end

        it do
          unused_user = User.find_by(account: account)

          expect(unused_user).to be_nil
        end
      end

      context "error record" do
        let(:csv_data) do
        <<EOS
#{SampleCsv.user_all_using_indexed_association_title.chomp}
,error-taro,2016 09 01 (15:31:21),Taro Error,"",13,,Hello!,Now on show,No,LongTagName,,,,,,,,,,,,,
EOS
        end

        it do
          expect(runner.errors.size).to eq 1
          expect(runner.errors[0]).to eq 'Entry1: TagNameOfPostByUser is too long (maximum is 5 characters)'
        end
      end
    end
  end
end
