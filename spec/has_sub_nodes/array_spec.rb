RSpec.describe NxtSchema do
  subject do
    NxtSchema.array(:developers) do |devs|
      devs.array(:frontend_devs) do |frontend_devs|
        frontend_devs.hash(:frontend_dev) do |frontend_dev|
          frontend_dev.node(:first_name, :String)
          frontend_dev.node(:last_name, :String)
        end
      end
    end
  end

  let(:input) { [[{ first_name: 'Igor', last_name: 'Yamov' }], [{ first_name: 'Ben', last_name: 'Arbogast' }, { first_name: nil }]] }

  it do
    result = subject.apply(input)

    expect(result.errors.all).to eq(
      :schema_errors=>{ 0=>[{:itself=>["1.0 violates constraints (type?(String, 1.0) failed)"]}] },
      :validation_errors=>{}
    )

    expect(result.output).to eq(input)
  end
end
