RSpec.describe NxtSchema::Registry do
  describe '#register' do
    subject do
      described_class.new
    end

    context 'when the key is not namespaced' do
      let(:key) { 'string' }
      let(:value) { 'String'}
      context 'and the key was not registered yet' do
        it 'registers the value' do
          subject.register(key, value)
          expect(subject[key]).to eq(value)
          expect(subject.resolve(key)).to eq(value)
        end
      end

      context 'and the key was already registered' do
        before do
          subject.register(:string, :String)
        end

        it 'raises an error' do
          expect { subject.register(:string, :String) }.to raise_error(KeyError)
        end
      end
    end

    context 'when the key is namespaced' do
      context 'and the key was not registered yet' do
        let(:key) { 'strict::string' }
        let(:value) { 'Strict::String' }

        it 'registers the value in the namespace' do
          subject.register(key, value)
          expect(subject[:strict][:string]).to eq(value)
          expect(subject.resolve(key)).to eq(value)
        end
      end

      context 'and the key was already registered' do
        before do
          subject.register('strict::string', 'Strict::String')
        end

        it 'raises an error' do
          expect { subject.register('strict::string', 'Strict::String') }.to raise_error(KeyError)
        end
      end
    end
  end

  describe '#resolve' do

  end
end
