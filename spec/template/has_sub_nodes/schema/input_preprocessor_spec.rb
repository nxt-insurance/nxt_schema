RSpec.describe NxtSchema do
  subject { schema.apply(input: input) }

  let(:input) do
    {
      'first_name' => 'Hanna',
      last_name: 'Robecke',
      address: {
        'street' => 'Am Waeldchen 9',
        town: 'Kaiserslautern'
      }
    }
  end

  describe '.preprocess_input' do
    context 'default input preprocessor' do
      let(:schema) do
        NxtSchema.schema(:person) do
          node(:first_name, type: :String)
          node(:last_name, type: :String)

          schema(:address, optional: true) do
            node(:street, type: :String)
            node(:town, type: :String)
          end

          optional(:phone, type: :String)
        end
      end

      it 'transforms all input keys of input hashes to symbols' do
        expect(subject).to be_valid
      end
    end

    context 'when switched off' do
      let(:schema) do
        NxtSchema.schema(:person, preprocess_input: false) do
          node(:first_name, type: :String)
          node(:last_name, type: :String)

          schema(:address, optional: true) do
            node(:street, type: :String)
            node(:town, type: :String)
          end

          optional(:phone, type: :String)
        end
      end

      it 'does not process inputs' do
        expect(subject).to_not be_valid
        expect(
          subject.errors
        ).to eq(
          "person"=>["The following keys are missing: [:first_name]"],
          "person.first_name"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"],
          "person.address"=>["The following keys are missing: [:street]"],
          "person.address.street"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"]
        )
      end
    end
  end
end
