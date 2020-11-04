RSpec.describe NxtSchema do
  subject do
    schema.apply(input)
  end

  context 'any of leaf nodes' do
    let(:schema) do
      NxtSchema.schema(:scores) do |scores|
        scores.any_of(:score) do |score|
          score.node(:integer, :Integer)
          score.node(:string, :String)
        end
      end
    end

    context 'when the input matches one of the schemas' do
      let(:input) { { score: 1 } }

      it { expect(subject).to be_valid }

      it 'returns the correct output' do
        expect(subject.output).to eq(input)
      end
    end

    context 'when the input matches none of the schemas' do
      let(:input) { { score: 1.to_d } }

      it { expect(subject).to_not be_valid }

      it 'returns the correct schema errors' do
        expect(subject.schema_errors).to eq({ })
      end
    end
  end
end