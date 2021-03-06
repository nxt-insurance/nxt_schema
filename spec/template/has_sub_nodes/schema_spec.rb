RSpec.describe NxtSchema do
  subject { schema.apply(input: input) }

  context 'hash with leaf nodes' do
    let(:schema) do
      NxtSchema.schema(:company, type_system: NxtSchema::Types::Coercible) do |company|
        company.node(:name, :String)
        company.node(:value, :Decimal)
      end
    end

    context 'when the input is valid' do
      let(:input) do
        { name: 'Getsafe', value: '10_000_000_000' }
      end

      it { expect(subject).to be_valid }

      it 'returns the correct output' do
        expect(subject.output).to eq(
          name: 'Getsafe',
          value: 10_000_000_000.to_d
        )
      end
    end

    context 'when the input violates the schema' do
      let(:input) do
        { name: 'Getsafe', value: 'a lot' }
      end

      it { expect(subject).to_not be_valid }

      it 'returns the correct output' do
        expect(subject.errors).to eq("company.value"=>["invalid value for BigDecimal(): \"a lot\""])
      end
    end
  end

  context 'hash with hash nodes' do
    let(:schema) do
      NxtSchema.schema(:company) do |company|
        company.node(:name, :String)
        company.node(:customers, :Integer)
        company.schema(:address) do |address|
          address.node(:street, :String)
          address.node(:street_number, :Integer)
          address.node(:zip_code, :Integer)
        end
      end
    end

    context 'when the input is valid' do
      let(:input) do
        {
          name: 'Getsafe',
          customers: 10_000_000,
          address: { street: 'Langer Anger', street_number: 7, zip_code: 67661 }
        }
      end

      it { expect(subject).to be_valid }

      it 'returns the correct output' do
        expect(subject.output).to eq(input)
      end
    end

    context 'when the input violates the schema' do
      let(:input) do
        { name: 'Getsafe', customers: 'a lot' }
      end

      it { expect(subject).to_not be_valid }

      it 'returns the correct output' do
        expect(subject.errors).to eq(
          "company"=>["The following keys are missing: [:address]"],
          "company.customers"=>["\"a lot\" violates constraints (type?(Integer, \"a lot\") failed)"],
          "company.address"=>["NxtSchema::Undefined violates constraints (type?(Hash, NxtSchema::Undefined) failed)"]
        )
      end
    end
  end

  context 'hash with array of nodes' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.node(:name, :String)
        person.collection(:houses) do |houses|
          houses.schema(:house) do |address|
            address.node(:street, :String)
            address.node(:street_number, :Integer)
            address.node(:zip_code, :Integer)
          end
        end
      end
    end

    context 'when the input is valid' do
      let(:input) do
        {
          name: 'Nils',
          houses: [
            { street: 'Langer Anger', street_number: 7, zip_code: 67661 },
            { street: 'Kirchgasse', street_number: 1, zip_code: 68150 },
            { street: 'Kimmelgarten', street_number: 11, zip_code: 67661 }
          ]
        }
      end

      it { expect(subject).to be_valid }

      it 'returns the correct output' do
        expect(subject.output).to eq(input)
      end
    end

    context 'when the input violates the schema' do
      let(:input) do
        {
          houses: [
            { street: 'Langer Anger', street_number: 7 },
            { street: nil, street_number: 1, zip_code: 68150 },
            { street: 1, street_number: 11, zip_code: '67661' }
          ]
        }
      end

      it { expect(subject).to_not be_valid }

      it 'returns the correct errors' do
        expect(subject.errors).to eq(
          "person"=>["The following keys are missing: [:name]"],
          "person.name"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"],
          "person.houses.house[0]"=>["The following keys are missing: [:zip_code]"],
          "person.houses.house[0].zip_code"=>["NxtSchema::Undefined violates constraints (type?(Integer, NxtSchema::Undefined) failed)"],
          "person.houses.house[1].street"=>["nil violates constraints (type?(String, nil) failed)"],
          "person.houses.house[2].street"=>["1 violates constraints (type?(String, 1) failed)"],
          "person.houses.house[2].zip_code"=>["\"67661\" violates constraints (type?(Integer, \"67661\") failed)"]
        )
      end
    end
  end

  context 'without sub nodes' do
    it { expect { NxtSchema.schema {} }.to raise_error NxtSchema::Errors::InvalidOptions }
  end
end
