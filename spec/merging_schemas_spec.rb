RSpec.describe NxtSchema do
  let(:schema) do
    address = address_schema

    NxtSchema.schema(:person) do
      required(:first_name, :String)
      required(:last_name, :String)
      required(:address, address)
    end
  end

  let(:address_schema) do
    NxtSchema.schema(:address) do
      required(:street, :String)
      required(:zip_code, :String)
      required(:town, :String)
    end
  end


  let(:input) do
    {
      first_name: 'Andy',
      last_name: 'Superstar',
      address: {
        street: 'Am Waeldchen 9',
        zip_code: '67661',
        town: 'Kaiserslautern'
      }
    }
  end

  subject do
    schema.apply(input)
  end

  it do
    expect(address_schema.parent_node).to be_nil
    expect(schema[:address].parent_node).to eq(schema)
    expect(subject).to be_valid
    expect(subject.output).to eq(input)
  end
end
