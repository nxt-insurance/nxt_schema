RSpec.describe NxtSchema::Template::Base do
  let(:schema) do
    NxtSchema.schema do
      multiply_type = lambda do |x|
        return x * x if x.is_a?(Integer)

        raise NxtSchema::Errors::CoercionError, "#{x} must be an integer"
      end

      required(:multiply, multiply_type)
    end
  end

  context 'procs as types' do
    let(:subject) { schema.apply!(input: input) }

    context 'when the type can be applied' do
      let(:input) { { multiply: 12 } }

      it 'uses the proc as type' do
        expect(subject).to eq(multiply: 144)
      end
    end

    context 'when the type cannot be applied' do
      let(:input) { { multiply: 12.to_d } }

      it 'raises an error' do
        expect { subject }.to raise_error NxtSchema::Errors::Invalid, '{"roots.multiply"=>["12.0 must be an integer"]}'
      end
    end
  end
end
