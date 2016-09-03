require 'spec_helper'

class SampleModeler < ActiveRecord::Bixformer::Modeler::Csv
  def model_name
    :user
  end

  def entry_definitions
    {
      attributes: {
        id: :base,
        account: :base,
        joined_at: [:time, format: :ymdhms]
      },
      associations: {
        profile: {
          attributes: {
            name: :base,
            age: :base
          }
        },
        posts: {
          type: [:indexed, size: 3],
          attributes: {
            id: :base,
            status: :enumerize,
            secret: :booletania
          },
          associations: {
            tags: {
              type: [:indexed, size: 2],
              attributes: {
                name: :base
              }
            }
          }
        }
      }
    }
  end
  def optional_attributes
    [
      :id,
    ]
  end
end

describe ActiveRecord::Bixformer::Runner::Csv do
  let(:runner) { ActiveRecord::Bixformer::Runner::Csv.new }
  let(:modeler) { SampleModeler.new }
  let(:csv_options) { {} }

  describe "#import" do
    before do
      ENV['TZ'] = 'Asia/Tokyo'

      runner.add_modeler(modeler); runner.import(csv_data, csv_options)
    end

    context "simple" do
      let(:csv_data) do
        <<EOS
UserSystemCode,AccountName,JoinTime,Name,Age,PostSystemCode1,Status1,IsSecret1,UserPost1TagName1,UserPost1TagName2,PostSystemCode2,Status2,IsSecret2,UserPost2TagName1,UserPost2TagName2,PostSystemCode3,Status3,IsSecret3,UserPost3TagName1,UserPost3TagName2
1,y-taro,2016 09 01 (15:31:21),Taro Yamada,24,1,Write in Process,Yes,Foo,Fuga,2,Now on show,No,,,,,,,
EOS
      end

      it do
        expect(runner.errors.size).to eq 0
        expect(User.all.size).to eq 1
        expect(User.all.first.account).to eq 'y-taro'
        expect(User.all.first.joined_at).to eq Time.new(2016, 9, 1, 15, 31, 21, "+09:00")
        expect(User.all.first.profile.name).to eq 'Taro Yamada'
        expect(User.all.first.profile.age).to eq 24
        expect(User.all.first.posts.size).to eq 2
        expect(User.all.first.posts[0].status).to eq :wip
        expect(User.all.first.posts[1].status).to eq :published
        expect(User.all.first.posts[0].secret).to be_truthy
        expect(User.all.first.posts[1].secret).to be_falsey
        expect(User.all.first.posts[0].tags.size).to eq 2
        expect(User.all.first.posts[1].tags.size).to eq 0
      end
    end
  end

  describe "#export" do
    subject { runner.add_modeler(modeler); runner.export(resource, csv_options) }

    context "resource is a list of ActiveRecord" do
      let(:joined_at) { Time.new(2016, 9, 1, 15, 31, 21, "+00:00") }
      let(:user) { User.new(account: 'y-taro', joined_at: joined_at) }

      let(:resource) do
        user.save!

        user.build_profile(name: 'Taro Yamada', age: 24).save!

        user.posts.build(status: :wip, secret: true).save!
        user.posts.build(status: :published, secret: false).save!

        user.posts.first.tags.build(name: 'Hoge').save!
        user.posts.first.tags.build(name: 'Fuga').save!
        user.posts.first.tags.build(name: 'Foo').save!

        [user]
      end

      it do
        expect_value = <<EOS
UserSystemCode,AccountName,JoinTime,Name,Age,PostSystemCode1,Status1,IsSecret1,UserPost1TagName1,UserPost1TagName2,PostSystemCode2,Status2,IsSecret2,UserPost2TagName1,UserPost2TagName2,PostSystemCode3,Status3,IsSecret3,UserPost3TagName1,UserPost3TagName2
#{user.id},y-taro,2016 09 01 (15:31:21),Taro Yamada,24,#{user.posts[0].id},Write in Process,Yes,Foo,Fuga,#{user.posts[1].id},Now on show,No,,,,,,,
EOS

        is_expected.to eq expect_value
      end
    end
  end
end
