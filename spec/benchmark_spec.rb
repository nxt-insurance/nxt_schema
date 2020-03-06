require 'benchmark'

RSpec.describe NxtSchema do
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

  let!(:values) do
    employee_names = 10.times.map do |index|
      { firstname: "first_name_#{index}", lastname: "last_name_#{index}" }
    end

    100.times.map do |index|
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

  let!(:profiler) { MethodProfiler.observe(NxtSchema::Node::Base) }

  subject do
    Benchmark.measure { schema.apply(values) }.real
  end

  it do
    puts " Benchmark =====> #{subject}"
    puts profiler.report
  end
end
