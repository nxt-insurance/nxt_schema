RSpec.describe NxtSchema do
  subject do
    NxtSchema.array(:developers, type_system: NxtSchema::Types::Params).any_of do |devs|
      devs.node(:dev, :Float)
    end
  end

  it do
    result = subject.apply([1, 2, 'Andy']).output
    expect(result).to eq(%w[1 2 Andy])
  end
end
