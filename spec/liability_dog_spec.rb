RSpec.describe NxtSchema do
  let(:subject) do
    NxtSchema.root(:claim_data) do
      required(:name_of_the_dog, :String)
      schema(:owner, optional: ->(node) { node[:name_of_the_dog] == 'Fifi' }) do
        required(:first_name, :String)
        required(:last_name, :String)
      end
    end
  end


  it do
    expect(subject.apply({ name_of_the_dog: 'Fifi' })).to be_valid
    expect(subject.apply({ name_of_the_dog: 'Rex' })).to_not be_valid
  end
end
