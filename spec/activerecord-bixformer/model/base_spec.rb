require 'spec_helper'

class SampleModel < ActiveRecord::Bixformer::Model::Base
  def make_import_value(attribute_name)
    
  end
end

class SampleModeler < ActiveRecord::Bixformer::Modeler::Base
  def initialize(entry_definitions, optional_attributes)
    @entry_definitions = entry_definitions
    @optional_attributes = optional_attributes
  end
  def model_name
    :user
  end
  def entry_definitions
    @entry_definitions
  end
  def optional_attributes
    @optional_attributes
  end
end

describe ActiveRecord::Bixformer::Model::Base do
  let(:model) { SampleModel.new(model_or_association_name, options) }
  let(:modeler) { SampleModeler.new(entry_definitions, optional_attributes) }
  let(:model_or_association_name) { :user }
  let(:options) { nil }
  let(:entry_definitions) do
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
  let(:optional_attributes) do
    [
      :id,
    ]
  end

  before do
    model.setup_with_modeler(modeler)
  end

  describe "#generate_import_value_map" do
    subject { model.generate_import_value_map }

    context "" do
      it { exp }
    end
  end
end
