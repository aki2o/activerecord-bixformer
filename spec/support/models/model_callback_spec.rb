require 'spec_helper'

module ActiveRecord::Bixformer::Model::Spec
end

module CallbackLogging
  extend ActiveSupport::Concern

  included do
    attr_reader :callback_logs

    def initialize(model_or_association_name, options)
      super

      @callback_logs = []
    end
  end
end

module CallbackExport
  extend ActiveSupport::Concern

  include CallbackLogging

  included do
    bixformer_before_export do
      @callback_logs << "Before export!"
    end

    bixformer_after_export :logging_after_export

    def logging_after_export(result)
      @callback_logs << "After export!"
    end

    bixformer_before_export :logging_before_association_export, type: :association

    def logging_before_association_export
      @callback_logs << "Before export association!"
    end

    bixformer_after_export on: :account do |result|
      @callback_logs << "After export account : #{result}!"
    end

    bixformer_around_export on: :account do |body|
      result = body.call

      @callback_logs << "Around export account : #{result}!"

      "hoge"
    end
  end
end

module CallbackImport
  extend ActiveSupport::Concern

  include CallbackLogging

  included do
    bixformer_before_import do
      @callback_logs << "Before import!"
    end

    bixformer_after_import :logging_after_import

    def logging_after_import(result)
      @callback_logs << "After import!"
    end

    bixformer_before_import type: :association do
      @callback_logs << "Before import association!"
    end

    bixformer_after_import :logging_after_account_import, on: :account

    def logging_after_account_import(result)
      @callback_logs << "After import account : #{result}!"
    end

    bixformer_around_import :logging_around_account_import, on: :account

    def logging_around_account_import
      result = yield

      @callback_logs << "Around import account : #{result}!"

      "hoge"
    end
  end
end

shared_examples_for "ActiveRecord::Bixformer::ModelCallback" do |export_user, import_data, model_args = nil|
  let(:model) { compiler.compile }
  let(:compiler) do
    ActiveRecord::Bixformer::Compiler.new(
      :spec,
      SampleUserPlan.new(
        entry: {
          type: [model_type, model_args],
          attributes: { account: :string },
          associations: { profile: {} }
        }
      )
    )
  end
  let(:model_type) { described_class.to_s.underscore.split('/')[4] }

  subject { model.callback_logs }

  before do
    format = described_class.to_s.underscore.split('/')[3].classify
    klass  = model_type.classify

    eval <<-EOS
class ActiveRecord::Bixformer::Model::Spec::#{klass} < ActiveRecord::Bixformer::Model::#{format}::#{klass}
  include #{callback_module}
end
EOS
  end

  context "export patern" do
    let(:callback_module) { CallbackExport }
    let(:expect_value) do
      [
        "Before export!",
        "Around export account : sample-taro!",
        "After export account : hoge!",
        "Before export association!",
        "After export!"
      ]
    end

    before { model.export(export_user) }

    it { is_expected.to eq expect_value }
  end

  context "import patern" do
    let(:callback_module) { CallbackImport }
    let(:expect_value) do
      [
        "Before import!",
        "Around import account : import-taro!",
        "After import account : hoge!",
        "Before import association!",
        "After import!"
      ]
    end

    before { model.import(import_data) }

    it { is_expected.to eq expect_value }
  end
end
