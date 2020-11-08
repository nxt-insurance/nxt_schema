RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'any of multiple schemas' do
    let(:schema) do
      NxtSchema.any_of(:contacts) do |contact|
        contact.schema(:female) do |female|
          female.required(:first_name, :String)
          female.required(:last_name, :String)
          female.required(:female, :Bool)
        end

        contact.schema(:male) do |male|
          male.required(:first_name, :String)
          male.required(:last_name, :String)
          male.required(:male, :Bool)
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
        expect(subject.schema_errors).to eq(
          female: {
            itself: ["The following keys are missing: [:first_name, :last_name, :female]"],
            first_name: ["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
            last_name: ["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
            female: ["NxtSchema::MissingInput violates constraints (type?(FalseClass, NxtSchema::MissingInput) failed)"]},
          male: {
            itself: ["The following keys are missing: [:first_name, :last_name, :male]"],
            first_name: ["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
            last_name: ["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
            male: ["NxtSchema::MissingInput violates constraints (type?(FalseClass, NxtSchema::MissingInput) failed)"]
          }
        )
      end
    end
  end
end
