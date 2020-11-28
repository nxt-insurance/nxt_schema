RSpec.describe NxtSchema do
  subject { schema.apply(input: input) }

  context 'when some nodes are optional' do
    let(:schema) do
      NxtSchema.schema(:person, transform_keys: ->(key) { key.to_s.upcase }) do |person|
        person.node(:first_name, :String)
        person.node(:last_name, :String)

        person.schema(:address, optional: true) do |address|
          address.node(:street, :String)
          address.node(:town, :String)
        end

        person.optional(:phone, :String)
      end
    end

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

    it do
      expect(subject.output).to eq(
        "FIRST_NAME" => "Hanna",
        "LAST_NAME" => "Robecke",
        "ADDRESS" => {"STREET"=>"Am Waeldchen 9", "TOWN"=>"Kaiserslautern"}
      )
    end
  end
end
