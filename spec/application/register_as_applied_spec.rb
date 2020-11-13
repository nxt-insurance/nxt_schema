RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  let(:schema) do
    NxtSchema.schema(:person) do
      node(:first_name, :String)
      node(:last_name, :String)

      collection(:nick_names) do
        node(:nick_name, :String)
      end

      collection(:addresses) do
        schema(:address) do |address|
          address.node(:street, :String)
          address.node(:town, :String)
        end
      end

      optional(:phone, :String)
    end
  end

  let(:input) do
    {
      first_name: 'Andy',
      nick_names: ['Superman', 'Superstar', 1, 2.to_d, Object.new],
      addresses: nil,
      phone: 123
    }
  end

  it 'returns only nodes that could be applied without schema errors' do
    expect(subject.applied_nodes.map(&:error_key)).to match_array([
      'person.first_name',
      'person.nick_names',
      'person.nick_names.nick_name[0]',
      'person.nick_names.nick_name[1]'
    ])
  end
end
