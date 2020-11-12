# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input)
  end

  let(:schema) do
    NxtSchema.schema(:person) do
      required(:first_name, :String)
      required(:last_name, :String).validate(:equal_to, 'Superstar')
    end
  end

  context 'when the input is valid' do
    let(:input) { { first_name: 'Andy', last_name: 'Superstar' } }

    it do
      expect(subject).to be_valid
    end
  end

  context 'when the input is not valid' do
    let(:input) { { first_name: 'Andy', last_name: 'Super Hero' } }

    it do
      expect(subject).to_not be_valid
    end
  end
end
