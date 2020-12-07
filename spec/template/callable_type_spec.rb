RSpec.describe NxtSchema::Template::Base do
  let(:schema) do
    NxtSchema.schema do
      required(:multiply, ->(x) { x * x })
    end
  end

  context 'allow procs as types' do
    let(:input) { { multiply: 12 } }

    let(:subject) { schema.apply!(input: input) }

    it 'uses the proc as type' do
      expect(subject).to eq(multiply: 144)
    end
  end
end
