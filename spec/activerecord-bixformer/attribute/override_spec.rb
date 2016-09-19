require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Override do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Override.new(model, attribute_name, nil) }
  let(:model) { ActiveRecord::Bixformer::Model::Base.new(:post, nil) }
  let(:attribute_name) { :status }

  describe "#export" do
    subject { attribute.export('hoge') }

    before do
      expect(model).to receive(:override_export_status).and_return('called override method!')
    end

    it { is_expected.to eq 'called override method!' }
  end

  describe "#import" do
    subject { attribute.import('hoge') }

    before do
      expect(model).to receive(:override_import_status).and_return('called override method!')
    end

    it { is_expected.to eq 'called override method!' }
  end
end
