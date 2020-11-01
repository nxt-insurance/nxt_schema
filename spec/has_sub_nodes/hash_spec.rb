RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'hash with leaf nodes' do
    let(:schema) do
      NxtSchema.hash(:company, type_system: NxtSchema::Types::Coercible) do |company|
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
        expect(subject.schema_errors).to eq(:value => ["invalid value for BigDecimal(): \"a lot\""])
      end
    end
  end

  context 'hash with hash nodes' do
    let(:schema) do
      NxtSchema.hash(:company) do |company|
        company.node(:name, :String)
        company.node(:customers, :Integer)
        company.hash(:address) do |address|
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
        expect(subject.schema_errors).to eq(
          :address => ["nil violates constraints (type?(Hash, nil) failed)"],
          :customers => ["\"a lot\" violates constraints (type?(Integer, \"a lot\") failed)"]
        )
      end
    end
  end

  context 'hash with array of nodes' do
    let(:schema) do
      NxtSchema.hash(:person) do |person|
        person.node(:name, :String)
        person.array(:houses) do |houses|
          houses.hash(:house) do |address|
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
        expect(subject.schema_errors).to eq(
          {
            name: ["nil violates constraints (type?(String, nil) failed)"],
            houses: {
              0 => { zip_code: ["nil violates constraints (type?(Integer, nil) failed)"] },
              1 => { street: ["nil violates constraints (type?(String, nil) failed)"] },
              2 => {
                street: ["1 violates constraints (type?(String, 1) failed)"],
                zip_code: ["\"67661\" violates constraints (type?(Integer, \"67661\") failed)"]
              }
            }
          }
        )
      end
    end
  end
end
