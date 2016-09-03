require 'spec_helper'

describe ActiveRecord::Bixformer::Attribute::Override do
  let(:attribute) { ActiveRecord::Bixformer::Attribute::Override.new(model, attribute_name, nil) }
  let(:model) { ActiveRecord::Bixformer::Model::Base.new(:post, nil) }
  let(:attribute_name) { :status }

  describe "#make_export_value" do
    subject { attribute.make_export_value('hoge') }

    before do
      expect(model).to receive(:override_export_status).and_return('called override method!')
    end

    it { is_expected.to eq 'called override method!' }
  end

  describe "#make_import_value" do
    subject { attribute.make_import_value('hoge') }

    before do
      expect(model).to receive(:override_import_status).and_return('called override method!')
    end

    it { is_expected.to eq 'called override method!' }
  end
end
