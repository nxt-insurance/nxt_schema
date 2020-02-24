RSpec.describe NxtSchema::Validations::Validators::Inclusion do
  let(:node) { NxtSchema::Node::Leaf.new(name: :test, type: :Integer, parent_node: nil) }
  let(:validation_errors) { node.validation_errors = {} }

  subject do
    NxtSchema::Validations::Registry::VALIDATORS.resolve(:inclusion).new([1,2,3]).build.call(node, value)
  end

  context 'when it is valid' do
    let(:value) { 3 }

    it do
      expect { subject }.to_not change { validation_errors }
    end
  end

  context 'when it is invalid' do
    let(:value) { 4 }

    it do
      expect { subject }.to change { validation_errors }.from({}).to(:itself=>["4 not included in [1, 2, 3]"])
    end
  end
end

