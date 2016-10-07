require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::FormattedForeignKey do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::FormattedForeignKey.new(model, attribute_name, options) }
  let(:model) { ActiveRecord::Bixformer::Model::Base.new(:user, nil) }
  let(:attribute_name) { :group_id }
  let(:record) { User.new("#{attribute_name}" => value) }

  describe "#export" do
    subject { attribute.export(record) }

    context "no value" do
      let(:value) { nil }
      let(:options) { { by: :name } }

      it { is_expected.to eq nil }
    end

    context "by attribute" do
      let(:value) { Group.find_or_create_by!(name: 'hoge').id }
      let(:options) { { by: :name } }

      it { is_expected.to eq 'hoge' }
    end

    context "by proc" do
      let(:value) { Group.find_or_create_by!(name: 'hoge').id }
      let(:options) do
        {
          by: -> (r) { format('name:%s', r.name) },
          find_by: -> (v) { { name: v.split(':').last } }
        }
      end

      it { is_expected.to eq 'name:hoge' }
    end
  end

  describe "#import" do
    subject { attribute.import(value) }

    context "no value" do
      let(:value) { nil }
      let(:options) { { by: :name } }

      it { is_expected.to eq nil }
    end

    context "by attribute" do
      let(:value) { 'hoge' }
      let(:options) { { by: :name } }

      it { is_expected.to eq Group.find_by(name: 'hoge').id }
    end

    context "by attribute" do
      let(:value) { 'name:hoge' }
      let(:options) do
        {
          by: -> (r) { format('name:%s', r.name) },
          find_by: -> (v) { { name: v.split(':').last } }
        }
      end

      it { is_expected.to eq Group.find_by(name: 'hoge').id }
    end

    context "has scope" do
      let(:value) { 'hoge' }
      let(:options) { { by: :name, scope: :admins } }

      it { is_expected.to eq nil }

      context "exist admin group" do
        before { Group.find_or_create_by!(name: 'hoge', kind: 'admin') }

        it { is_expected.to eq Group.find_by(name: 'hoge', kind: 'admin').id }
      end
    end

    context "has scope as proc" do
      let(:value) { 'hoge' }
      let(:options) { { by: :name, scope: -> { Group.where(kind: 'guest') } } }

      it { is_expected.to eq nil }

      context "exist guest group" do
        before { Group.find_or_create_by!(name: 'hoge', kind: 'guest') }

        it { is_expected.to eq Group.find_by(name: 'hoge', kind: 'guest').id }
      end
    end

    context "not exist value" do
      let(:value) { 'fuga' }
      let(:options) { { by: :name } }

      it { is_expected.to eq nil }

      context "has create option" do
        let(:options) { { by: :name, create: true } }

        it { is_expected.to eq Group.find_by(name: 'fuga').id }
      end
    end

    context "has creator options" do
      let(:value) { 'bad!' }
      let(:options) { { by: :name } }

      it { is_expected.to eq nil }

      context "has create option" do
        let(:options) { { by: :name, create: true } }

        it { is_expected.to eq nil }
      end

      context "has create option with creator" do
        let(:options) { { by: :name, create: true, creator: :save! } }

        it { expect{subject}.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end
end
