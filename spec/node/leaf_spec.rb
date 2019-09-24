RSpec.describe NxtSchema::Node::Leaf do
  describe '#apply' do
    subject do
      described_class.new(name: :test, type: :String, parent_node: nil)
    end

    let(:value) { 'Andy' }
    let(:value_store) { {} }

    it do
      # TODO: Get rid of passing in parent value store
      subject.apply(value, parent_value_store: value_store)
      expect(subject.value).to eq("Andy")
    end
  end

  describe '#maybe' do
    subject do
      described_class.new(name: :test, type: :String, parent_node: nil, maybe: nil)
    end

    let(:value) { nil }
    let(:parent_value_store) { {} }

    it do
      # TODO: Get rid of passing in parent value store
      subject.apply(value, parent_value_store: parent_value_store)
      expect(subject.value).to eq(nil)
    end
  end

  describe '#default' do

  end

  describe '#validations' do

  end
end
