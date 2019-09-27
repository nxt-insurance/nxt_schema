RSpec.describe NxtSchema::Node::Leaf do
  describe '#apply' do
    subject do
      described_class.new(name: :test, type: :String, parent_node: nil)
    end

    let(:value) { 'Andy' }

    it do
      subject.apply(value)
      expect(subject.value).to eq("Andy")
    end
  end

  describe '#maybe' do
    subject do
      described_class.new(name: :test, type: :String, parent_node: nil, maybe: nil)
    end

    let(:value) { nil }

    it do
      subject.apply(value)
      expect(subject.value).to eq(nil)
    end
  end

  describe '#default' do

  end

  describe '#validations' do

  end
end
