RSpec.describe NxtSchema do
  subject do
    NxtSchema.array(:developers).any_of do |devs|
      devs.node(:dev, NxtSchema::Types::Integer | NxtSchema::Types::String)
    end
  end

  let(:input) { [1.0, 2, 'Andy'] }

  it do
    result = subject.apply(input)

    expect(result.errors.all).to eq(
      :schema_errors=>{ 0=>[{:itself=>["1.0 violates constraints (type?(String, 1.0) failed)"]}] },
      :validation_errors=>{}
    )

    expect(result.output).to eq(input)
  end
end
