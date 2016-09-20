require 'spec_helper'

describe ActiveRecord::Bixformer::Compiler do
  let(:compiler) { ActiveRecord::Bixformer::Compiler.new(format, plan) }
  let(:format) { :csv }
  let(:plan) { SampleUserPlan.new(plan_options) }
  let(:plan_options) do
    {
      entry: SampleEntry.user_all_using_indexed_association,
      preferred_skip_attributes: preferred_skip_attributes
    }
  end

  let(:preferred_skip_attributes) { [] }

  before do
    ENV['TZ'] = 'Asia/Tokyo'
  end

  describe "#compile" do
    let(:model) { compiler.compile }

    context "all" do
      it do
        expect(model.name).to eq "user"
        expect(model.attributes.map(&:name)).to eq ["id", "account", "joined_at"]
        expect(model.associations.map(&:name)).to eq ["profile", "posts"]

        profile = model.associations.find { |ass| ass.name == "profile" }

        expect(profile.attributes.map(&:name)).to eq ["name", "email", "age"]

        posts = model.associations.find { |ass| ass.name == "posts" }

        expect(posts.attributes.map(&:name)).to eq ["id", "content", "status", "secret"]
        expect(posts.associations.map(&:name)).to eq ["tags"]

        tags = posts.associations.find { |ass| ass.name == "tags" }

        expect(tags.attributes.map(&:name)).to eq ["name"]
      end
    end
  end
end
