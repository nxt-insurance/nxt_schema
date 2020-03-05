RSpec.describe NxtSchema::Validators::Exclusion do
  let(:node) { NxtSchema::Node::Leaf.new(name: :test, type: :Integer, parent_node: nil) }
  let(:validation_errors) { node.validation_errors = {} }

  subject do
    NxtSchema::Validators::Registry::VALIDATORS.resolve(:exclusion).new([1,2,3]).build.call(node, value)
  end

  context 'when it is valid' do
    let(:value) { 4 }

    it do
      expect { subject }.to_not change { validation_errors }
    end
  end

  context 'when it is invalid' do
    let(:value) { 1 }

    it do
      expect { subject }.to change { validation_errors }.from({}).to(:itself=>["[1, 2, 3] should not contain 1"])
    end
  end
end

