RSpec.describe NxtSchema do
  subject { schema.apply(input: input) }

  context 'when a type is provided for a schema' do
    let(:schema) do
      NxtSchema.schema(:person, type: NxtSchema::Types::Constructor(::OpenStruct)) do |person|
        person.node(:first_name, type: :String)
        person.node(:last_name, type: :String)

        person.schema(:address, optional: true) do |address|
          address.node(:street, type: :String)
          address.node(:town, type: :String)
        end

        person.optional(:phone, type: :String)
      end
    end

    let(:input) do
      {
        first_name: 'Hanna',
        last_name: 'Robecke',
        address: {
          street: 'Am Waeldchen 9',
          town: 'Kaiserslautern'
        },
        phone: '017696426299'
      }
    end

    it 'construct the objects' do
      expect(subject.output).to eq(OpenStruct.new(input))
    end
  end
end
