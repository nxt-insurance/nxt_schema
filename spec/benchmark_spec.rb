require 'benchmark'

RSpec.describe NxtSchema do
  context 'many instances' do
    let!(:schema) do
      NxtSchema.roots(:companies) do
        schema(:company) do
          requires(:name, :String)
          requires(:industry, :String)

          optional(:headquarter, :Schema).maybe(nil).default({}) do |headquarter|
            headquarter.node(:street, :String)
            headquarter.node(:street_number, :Integer).validate(:greater_than, 6).validate(:less_than, 8)
          end

          nodes(:employee_names) do |nodes|
            nodes.node(:employee_name_underscore, :Schema) do |employee_name|
              employee_name.node(:first_name, :String)
              employee_name.node(:last_name, :String)
            end

            nodes.schema(:employee_name) do |employee_name|
              employee_name.node(:firstname, :String)
              employee_name.node(:lastname, :String)
            end
          end
        end
      end
    end

    let(:count) { 100 }

    let!(:values) do
      employee_names = 20.times.map do |index|
        { firstname: "first_name_#{index}", lastname: "last_name_#{index}" }
      end

      count.times.map do |index|
        {
          name: 'getsafe',
          industry: 'insurance',
          headquarter: {
            street: 'Langer Anger',
            street_number: index
          },
          employee_names: employee_names
        }
      end
    end

    # make this bang to profile
    let(:profiler) { MethodProfiler.observe(NxtSchema::Node::Base) }

    subject do
      Benchmark.measure { schema.apply(values) }.real
    end

    it do
      puts " Benchmark #{count} deeply nested instances => #{subject}"
    end
  end

  context 'instances with many attributes' do
    let!(:schema) do
      NxtSchema.roots(:people) do
        schema(:person) do
          requires(:first_name, :String)
          requires(:last_name, :String)
          requires(:gender, NxtSchema::Types::Enums[*%w[female male]])
          requires(:email, :String).validate(:pattern, /\A.*@.*\z/)
          requires(:size, :Integer)
          requires(:weight, :Integer)
          requires(:birth_date, :Date)
          requires(:occupation, :String)
          requires(:nationality, NxtSchema::Types::Enums[*%w[German English French]])
          schema(:bank_account) do
            required(:bank, :String)
            required(:iban, :String).validate(:pattern, /\ADE\d+\z/)
          end
          schema(:address) do
            required(:street, :String)
            required(:street_number, :String)
            required(:city, :String)
            required(:zip_code, :String)
          end
        end
      end
    end

    let(:count) { 1000 }

    let!(:values) do
      count.times.map do |index|
        {
          first_name: "First name #{index}",
          last_name: "Last name #{index}",
          gender: %w[female male].shuffle.first,
          email: "person_#{index}@mail.com",
          size: 170 + rand(20),
          weight: 60 + rand(30),
          birth_date: index.days.ago,
          occupation: "Occupation #{index}",
          nationality: %w[German English French].shuffle.first,
          bank_account: {
            bank: "Bank #{index}",
            iban: "DE1726312983120#{index}",
          },
          address: {
            street: "Street #{index}",
            street_number: index,
            city: "City #{index}",
            zip_code: "#{index}#{index}#{index}#{index}#{index}"
          }
        }
      end
    end

    let(:profiler) { MethodProfiler.observe(NxtSchema::Node::Base) }

    subject do
      Benchmark.measure { schema.apply(values) }.real
    end

    it do
      puts " Benchmark #{count} instance with many attributes => #{subject}"
    end
  end
end
