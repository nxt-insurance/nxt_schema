# frozen_string_literal: true

RSpec.describe NxtSchema do
  let(:address_schema) do
    NxtSchema.schema(:address) do
      required(:street).typed(:String)
      required(:street_number).typed(:String)
      required(:city).typed(:String)
      required(:zip_code).typed(:String)
      required(:country).typed(:String).validate(:included_in, %w[Germany, France, UK])
    end
  end

  let(:schema) do
    address = address_schema

    NxtSchema.collection(:people) do
      schema(:person) do
        required(:first_name).typed(:String)
        required(:last_name).typed(:String)
        required(:birthdate).typed(:Date)
        required(:age).typed(:Integer)
        required(:email).typed(:String).validate(:pattern, /\A.*@.*\z/)
        required(:language).typed(:String).validate(:included_in, %w[de en fr])

        required(:address, type: address) # TODO: This is not the best DSL - maybe replace with another method or use a proxy for building?

        schema(:company) do
          required(:name).typed(:String)
          required(:position).typed(:String)
          required(:address, type: address)
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
