RSpec.describe NxtSchema do
  subject { schema.apply(input: input) }

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

  it 'returns only nodes that could be coerced without errors' do
    expect(subject.coerced_nodes.map(&:input)).to match_array(%w[Andy Superman Superstar])
  end
end
