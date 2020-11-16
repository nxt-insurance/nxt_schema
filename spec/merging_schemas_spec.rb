RSpec.describe NxtSchema do
  let(:schema) do
    address = address_schema
    cyphers = cyphers_schema

    NxtSchema.schema(:person) do
      required(:first_name, :String)
      required(:last_name, :String)
      required(:address, address)
      required(:cyphers, cyphers)
    end
  end

  let(:address_schema) do
    cyphers = cyphers_schema

    NxtSchema.schema(:address) do
      required(:street, :String)
      required(:zip_code, :String)
      required(:town, :String).validate(:equal_to, 'Kaiserslautern')
      node(:country, :String, optional: ->(node) { node[:town].input == 'Kaiserslautern' })
      required(:cyphers, cyphers)
    end
  end


  let(:cyphers_schema) do
    NxtSchema.collection do
      required(:cypher, :String)
    end
  end

  let(:input) do
    {
      first_name: 'Andy',
      last_name: 'Superstar',
      cyphers: %w[A N D],
      address: {
        street: 'Am Waeldchen 9',
        zip_code: '67661',
        town: 'Kaiserslautern',
        cyphers: %w[A N D]
      }
    }
  end

  subject do
    schema.apply(input)
  end

  it do
    expect(address_schema.parent_node).to be_nil
    expect(schema[:address].parent_node).to eq(schema)
    expect(schema[:cyphers].parent_node).to eq(schema)
    expect(schema[:address][:cyphers].parent_node).to eq(schema[:address])

    expect(subject).to be_valid
    expect(subject.output).to eq(input)
  end
end
