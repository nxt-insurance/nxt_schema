RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  context 'any of leaf nodes' do
    let(:schema) do
      NxtSchema.schema(:scores) do
        any_of(:score) do
          node(:integer, :Integer)
          node(:string, :String)
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
        expect(subject.errors).to eq(
          "scores.score.integer"=>["0.1e1 violates constraints (type?(Integer, 0.1e1) failed)"],
          "scores.score.string"=>["0.1e1 violates constraints (type?(String, 0.1e1) failed)"]
        )
      end
    end
  end

  context 'without sub nodes' do
    it { expect { NxtSchema.any_of {} }.to raise_error NxtSchema::Errors::InvalidOptions }
  end
end
