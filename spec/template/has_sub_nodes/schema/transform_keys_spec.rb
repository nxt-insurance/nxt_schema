RSpec.describe NxtSchema do
  subject { schema.apply(input: input) }

  context 'when some nodes are optional' do
    let(:schema) do
      NxtSchema.schema(:person, transform_output_keys: ->(key) { key.to_s.upcase }) do |person|
        person.node(:first_name).typed(:String)
        person.node(:last_name).typed(:String)

        person.schema(:address, optional: true) do |address|
          address.node(:street, type: :String)
          address.node(:town, type: :String)
        end

        person.optional(:phone, type: :String)
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
