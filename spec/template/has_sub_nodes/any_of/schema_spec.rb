RSpec.describe NxtSchema do
  subject { schema.apply(input: input) }

  context 'any of multiple schemas' do
    let(:schema) do
      NxtSchema.any_of(:contacts) do |contact|
        contact.schema do
          required(:first_name, type: :String)
          required(:last_name, type: :String)
          required(:female, type: :Bool)
        end

        contact.schema do
          required(:first_name, type: :String)
          required(:last_name, type: :String)
          required(:male, type: :Bool)
        end
      end
    end

    context 'when the input matches one of the schemas' do
      let(:input) do
        { first_name: 'Andy', last_name: 'Superstar', male: true }
      end

      it { expect(subject).to be_valid }

      it 'returns the correct output' do
        expect(subject.output).to eq(input)
      end
    end

    context 'when the input does not match one of the schemas' do
      let(:input) { {} }

      it { expect(subject).to_not be_valid }

      it 'returns the correct schema errors' do
        expect(subject.errors).to eq(
          "contacts.0"=>["The following keys are missing: [:first_name, :last_name, :female]"],
          "contacts.0.first_name"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"],
          "contacts.0.last_name"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"],
          "contacts.0.female"=>["NxtSchema::Undefined violates constraints (type?(FalseClass, NxtSchema::Undefined) failed)"],
          "contacts.1"=>["The following keys are missing: [:first_name, :last_name, :male]"],
          "contacts.1.first_name"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"],
          "contacts.1.last_name"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"],
          "contacts.1.male"=>["NxtSchema::Undefined violates constraints (type?(FalseClass, NxtSchema::Undefined) failed)"]
        )
      end
    end
  end
end
