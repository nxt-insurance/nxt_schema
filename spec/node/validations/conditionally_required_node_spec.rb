# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  let(:schema) do
    NxtSchema.schema(:contact) do
      required(:first_name, :String)
      required(:last_name, :String)
      node(:email, :String, required: ->(node) { node.up[:last_name].input == 'Superstar' })
    end
  end

  context 'when the node is conditionally required' do
    let(:input) do
      {
        first_name: 'Andy',
        last_name: 'Superstar'
      }
    end

    it { expect(subject).to_not be_valid }

    it 'returns the correct errors' do
      expect(subject.errors).to eq("contact"=>["Required key :email is missing"])
    end
  end

  context 'when the node is not conditionally required' do
    let(:input) do
      {
        first_name: 'Andy',
        last_name: 'Other'
      }
    end

    it { expect(subject).to be_valid }
  end
end
