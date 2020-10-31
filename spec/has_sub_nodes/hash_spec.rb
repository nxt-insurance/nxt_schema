RSpec.describe NxtSchema do
  subject do
    NxtSchema.hash(:developers, type_system: NxtSchema::Types::Coercible) do |devs|
      devs.node(:first_name, :String)
      devs.node(:last_name, :String)
    end
  end

  it do
    result = subject.apply(first_name: 'Andy', last_name: 1).output
    expect(result).to eq(first_name: 'Andy', last_name: '1')
  end

  context 'hash with leaf nodes' do

  end

  context 'hash with hash nodes' do

  end

  context 'hash with array of leaf nodes' do

  end
end
