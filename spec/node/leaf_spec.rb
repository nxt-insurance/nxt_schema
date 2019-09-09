RSpec.describe NxtSchema::Node::Leaf do
  describe '#apply' do
    subject do
      described_class.new(:test, :String, nil, {})
    end

    let(:value) { 'Andy' }
    let(:value_store) { {} }

    it do
      subject.apply(value, parent_value_store: value_store)
      expect(value_store).to eq(:test=>"Andy")
    end
  end

  describe '#maybe' do
    subject do
      described_class.new(:test, :String, nil, maybe: nil)
    end

    let(:value) { nil }
    let(:value_store) { {} }

    it do
      subject.apply(value, parent_value_store: value_store)
      expect(value_store).to eq(:test=>nil)
    end
  end
end
