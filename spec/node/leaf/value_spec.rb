RSpec.describe NxtSchema::Node::Leaf do
  describe '#apply' do
    context 'when there are schema errors' do
      let(:type) do
        NxtSchema::Type::Strict::String
      end

      subject do
        described_class.new(name: :leaf, type: type, parent_node: nil)
      end
    end

    context 'when there are no schema errors' do
      context 'when the maybe criteria applies' do

      end

      context 'when the maybe criteria does not apply' do

      end

      context 'when the node is optional' do

      end

      context 'when the node is not optional' do

      end
    end
  end
end
