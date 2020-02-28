RSpec.describe NxtSchema::Node::Constructor do
  context 'with nested structs' do
    subject do
      NxtSchema.roots do
        required(:level_1, NxtSchema::Types::Struct) do
          required(:name, :String)
          required(:level_2, NxtSchema::Types::Struct) do
            required(:name, :String)
            required(:level_3, NxtSchema::Types::Struct) do
              required(:name, :String)
              nodes(:attributes) do
                required(:attribute, NxtSchema::Types::Struct) do
                  required(:name, :String)
                end
              end
            end
          end
        end
      end
    end

    let(:schema) do
      [
        { name: 'Heaven', level_2: { name: 'Earth', level_3: { name: 'Hell', attributes: [{ name: 'Fire' }] } } },
        { name: 'Heaven', level_2: { name: 'Earth', level_3: { name: 'Hell', attributes: [{ name: 'Heat' }] } } }
      ]
    end

    it do
      subject.apply(schema)
      expect(subject).to be_valid

      expect(subject.value).to all(be_a(Struct))
    end
  end
end