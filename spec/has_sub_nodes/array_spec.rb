RSpec.describe NxtSchema do
  subject do
    NxtSchema.array(:developers).any_of do |devs|
      devs.node(:dev, :String)
    end
  end

  it do
    result = subject.apply([1, 2, 'Andy']).output
    expect(result).to eq(%w[1 2 Andy])
  end
end
