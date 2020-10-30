RSpec.describe NxtSchema do
  subject do
    NxtSchema.array(:developers) do |devs|
      devs.node(:dev, :String)
    end
  end

  it do
    result = subject.apply([1, 2, 'Andy'])
    binding.pry
  end
end
