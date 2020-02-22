RSpec.describe NxtSchema::Node::Leaf do
  describe '#validations' do
    let(:node) do
      described_class.new(name: :leaf, type: :Integer, parent_node: nil)
    end

    before do
      node.validate_with do
        validator(:greater_than, 5) &&
          validator(:greater_than, 6)
      end
    end

    it do
      binding.pry
    end
  end
end