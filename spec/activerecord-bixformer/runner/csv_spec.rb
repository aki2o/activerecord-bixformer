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
  describe "#export" do
    subject { runner.add_modeler(modeler); runner.export(resource, csv_options) }
    let(:runner) { ActiveRecord::Bixformer::Runner::Csv.new }
    let(:modeler) { SampleModeler.new }
    let(:csv_options) { {} }

    context "resource is a list of ActiveRecord" do
      let(:joined_at) { Time.current }

      let(:resource) do
        user = User.new(account: 'y-taro', joined_at: joined_at)
        user.save!

        user.build_profile(name: 'Taro Yamada', age: 24).save!

        user.posts.build(status: :wip, secret: true).save!
        user.posts.build(status: :published, secret: false).save!

        user.posts.first.tags.build(name: 'Hoge').save!
        user.posts.first.tags.build(name: 'Fuga').save!
        user.posts.first.tags.build(name: 'Foo').save!

        [user]
      end

      it { is_expected.to eq '' }
    end
  end
end
