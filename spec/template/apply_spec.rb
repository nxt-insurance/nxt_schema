RSpec.describe NxtSchema::Template::Base do
  let(:schema) do
    NxtSchema.nodes(:numbers) do
      validate(:attribute, :size, ->(s) { s > 3 })
      required(:number, :Integer)
    end
  end

  subject { schema.apply!(input: input) }

  describe '#apply!' do
    context 'when the input is valid' do
      let(:input) { [1, 2, 3, 4] }

      it 'returns the output' do
        expect(subject).to eq(input)
      end
    end

    context 'when the input is not valid' do
      let(:input) { [1, 2, 3] }

      it 'raises an error' do
        expect { subject }.to raise_error(NxtSchema::Errors::Invalid)
      end
    end
  end
end
