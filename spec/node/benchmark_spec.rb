# frozen_string_literal: true

RSpec.describe NxtSchema do
  let(:address_schema) do
    NxtSchema.schema(:address) do
      required(:street, :String)
      required(:street_number, :String)
      required(:city, :String)
      required(:zip_code, :String)
      required(:country, :String).validate(:included_in, %w[Germany, France, UK])
    end
  end

  let(:schema) do
    address = address_schema

    NxtSchema.collection(:people) do
      schema(:person) do
        required(:first_name, :String)
        required(:last_name, :String)
        required(:birthdate, :Date)
        required(:age, :Integer)
        required(:email, :String).validate(:pattern, /\A.*@.*\z/)
        required(:language, :String).validate(:included_in, %w[de en fr])

        required(:address, address)

        schema(:company) do
          required(:name, :String)
          required(:position, :String)
          required(:address, address)
        end
      end
    end
  end

  let(:input) do
    0.upto(1000).map do |index|
      {
        first_name: "Nico##{index}",
        last_name: "Stoianov#{index}",
        birthdate: Date.today + index.days,
        age: 20 + index,
        email: "nico#{index}@stoianov.com",
        language: %w[de en fr].sample,
        address: {
          street: "Langer Anger",
          street_number: index.to_s,
          city: 'Heidelberg',
          zip_code: index.to_s,
          country: %w[Germany, France, UK].sample
        },
        company: {
          name: 'Getsafe',
          position: 'Boss',
          address: {
            street: "Langer Anger",
            street_number: index.to_s,
            city: 'Heidelberg',
            zip_code: index.to_s,
            country: %w[Germany, France, UK].sample
          }
        }
      }
    end
  end

  before { input } # memoize

  subject { Benchmark.measure { schema.apply(input: input) }.real }

  it do
    expect(subject).to be_between(0.0, 0.3)
  end
end
