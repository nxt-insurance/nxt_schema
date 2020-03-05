RSpec.describe NxtSchema do
  describe '.register_type' do
    before do
      described_class.register_type(
        :MyCustomStrippedString,
        NxtSchema::Types::Strict::String.constructor(->(string) { string&.strip })
      )
    end

    let(:schema) do
      NxtSchema.root(:company) do
        required(:name, NxtSchema::Types::MyCustomStrippedString)
      end
    end

    it 'registers the type' do
      expect(
        schema.apply(name: '   getsafe   ').value
      ).to eq(name: 'getsafe')
    end
  end
end
