RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  context 'any of within a collection' do
    let(:schema) do
      NxtSchema.collection(:scores) do |scores|
        scores.any_of(:score) do |score|
          score.node(:integer, :Integer)
          score.node(:string, :String)
        end
      end
    end

    context 'when all inputs match one of the schemas' do
      let(:input) { [1, '2', 3, 'vier'] }

      it { expect(subject).to be_valid }

      it 'returns the correct output' do
        expect(subject.output).to eq(input)
      end
    end

    context 'when some inputs do not match any of the schemas' do
      let(:input) { [1, '2', 3, 4.to_d, nil] }

      it { expect(subject).to_not be_valid }

      it 'returns the correct schema errors' do
        expect(subject.errors).to eq(
          "scores.score[3].integer"=>["0.4e1 violates constraints (type?(Integer, 0.4e1) failed)"],
          "scores.score[3].string"=>["0.4e1 violates constraints (type?(String, 0.4e1) failed)"],
          "scores.score[4].integer"=>["nil violates constraints (type?(Integer, nil) failed)"],
          "scores.score[4].string"=>["nil violates constraints (type?(String, nil) failed)"]
        )
      end
    end
  end
end
