RSpec.describe NxtSchema::Template::TypeResolver do
  context 'with default type system' do
    context 'when the type exists in the default type system' do
      let(:schema) do
        NxtSchema.schema do
          required(:name, :String)
        end
      end

      subject { schema.sub_nodes[:name].type }

      it 'resolves the type' do
        expect(subject).to be_a(Dry::Types::Constrained)
      end
    end

    context 'when the type was registered' do
      let(:schema) do
        NxtSchema.schema do
          required(:name, :StrippedString)
        end
      end

      subject { schema.sub_nodes[:name].type }

      it 'resolves the type' do
        expect(subject).to be_a(Dry::Types::Constructor)
      end
    end

    context 'when the type cannot be resolved' do
      let(:schema) do
        NxtSchema.schema do
          required(:name, :DoesNotExist)
        end
      end

      subject { schema.sub_nodes[:name].type }

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError, /Can't resolve type: .*/)
      end
    end
  end

  context 'with custom type system' do
    context 'when the type exists in the custom type system' do
      let(:schema) do
        NxtSchema.schema(type_system: NxtSchema::Types::JSON) do
          required(:date, :Date)
        end
      end

      subject { schema.sub_nodes[:date].type }

      it 'resolves the type' do
        expect(subject).to be_a(Dry::Types::Constructor)
      end
    end

    context 'when the type was registered' do
      let(:schema) do
        NxtSchema.schema(type_system: NxtSchema::Types::JSON) do
          required(:name, :StrippedString)
        end
      end

      subject { schema.sub_nodes[:name].type }

      it 'resolves the type' do
        expect(subject).to be_a(Dry::Types::Constructor)
      end
    end

    context 'when the type cannot be resolved' do
      let(:schema) do
        NxtSchema.schema(type_system: NxtSchema::Types::JSON) do
          required(:name, :DoesNotExist)
        end
      end

      subject { schema.sub_nodes[:name].type }

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError, /Can't resolve type: .*/)
      end
    end
  end
end
