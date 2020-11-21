# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  let(:schema) do
    NxtSchema.schema(:contact) do
      required(:first_name, :String)
      required(:age, :Integer).validate_with do
        validator(:greater_than, 18) &&
          validator(:greater_than, 19) &&
          validator(:less_than, 21)
      end
    end
  end

  context 'when the input violates some validators' do
    let(:input) { { first_name: 'Nils', age: 19 } }

    it { expect(subject).to_not be_valid }
    it { expect(subject.errors).to eq("contact.age" => ["19 must be greater than 19"]) }
  end

  context 'when the input violates all validators' do
    let(:input) { { first_name: 'Nils', age: 17 } }

    it { expect(subject).to_not be_valid }
    it { expect(subject.errors).to eq("contact.age" => ["17 must be greater than 18"]) }
  end

  context 'when the input violates none of the validators' do
    let(:input) { { first_name: 'Nils', age: 20 } }

    it { expect(subject).to be_valid }
  end
end
