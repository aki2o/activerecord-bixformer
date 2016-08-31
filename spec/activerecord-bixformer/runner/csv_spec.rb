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
        joined_at: :base
      },
      associations: {
        profile: {
          attributes: {
            name: :base,
            age: :base
          }
        },
        posts: {
          type: :indexed,
          arguments: {
            size: 5,
          },
          attributes: {
            id: :base,
            status: :enumerize,
            private: :boolean
          },
          associations: {
            tags: {
              type: :indexed,
              arguments: {
                size: 3,
              },
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
      let(:resource) do
        user = User.new(account: 'y-taro', joined_at: Time.current)
        user.save!

        user.build_profile(name: 'Taro Yamada').save!

        user.build_posts.save!

        [user]
      end

      it { is_expected.to eq '' }
    end
  end
end
