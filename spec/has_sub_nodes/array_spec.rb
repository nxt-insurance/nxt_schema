RSpec.describe NxtSchema do
  subject do
    NxtSchema.array(:developers).any_of do |devs|
      devs.node(:dev, NxtSchema::Types::Integer | NxtSchema::Types::String)
    end
  end

  it do
    result = subject.apply([1.0, 2.5, 'Andy'])

    expect(result.errors.all).to eq(
      :schema_errors=>{
        0=>[{:itself=>["1.0 violates constraints (type?(String, 1.0) failed)"]}],
        1=>[{:itself=>["2.5 violates constraints (type?(String, 2.5) failed)"]}]},
      :validation_errors=>{}
    )
  end
end
