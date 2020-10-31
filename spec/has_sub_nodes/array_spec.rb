RSpec.describe NxtSchema do
  subject do
    NxtSchema.array(:developers).any_of do |devs|
      devs.node(:dev, NxtSchema::Types::Integer | NxtSchema::Types::String)
    end
  end

  it do
    result = subject.apply([1, 2, 'Andy']).output
    expect(result).to eq([1, 2, 'Andy'])
  end
end
