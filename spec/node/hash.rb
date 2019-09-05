RSpec.describe NxtSchema::Node::Hash do
  subject do
    described_class.new('test', nil, {}) do |node|
      node.requires(:first_name, :String)
      node.requires(:last_name, :String)
    end
  end

  let(:schema) do
    { first_name: 'Andy', last_name: 'Robecke' }
  end

  describe '#apply' do
    it do
      expect(subject.apply(schema)).to eq(subject)
    end
  end
end
