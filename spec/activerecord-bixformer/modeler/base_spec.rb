require 'spec_helper'

describe ActiveRecord::Bixformer::Modeler::Base do
  let(:modeler) { ActiveRecord::Bixformer::Modeler::Base.new(:csv) }

  describe "#parse_to_type_and_options" do
    subject { modeler.parse_to_type_and_options(value) }

    context "with hash" do
      let(:value) { [:indexed, size: 2] }

      it { is_expected.to eq [:indexed, {size: 2}] }
    end
  end
end
