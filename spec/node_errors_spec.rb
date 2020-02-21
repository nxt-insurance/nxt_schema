RSpec.describe NxtSchema do
  describe '#apply' do
    context 'array with leaf nodes' do
      subject do
        NxtSchema.new do |root|
          root.nodes(:company) do |company|
            company
          end
        end
      end
    end

    context 'hash with leaf nodes' do
      subject do
        NxtSchema.new do |root|
          root.schema(:company) do |company|
            company.requires(:name, :String)
            company.requires(:industry, :String)
          end
        end
      end

      context 'when a key is missing' do
        let(:schema) do
          { company: { name: 'getsafe' } }
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors).to eq(:company=>{:itself=>["Required key :industry is missing in {:name=>\"getsafe\"}"]})
        end
      end

      context 'when the value is of the wrong type' do
        let(:schema) do
          { company: { name: 'getsafe', industry: true } }
        end

        it do
          subject.apply(schema)

          expect(subject.validation_errors).to eq(:company=>{:industry=>{:itself=>["true violates constraints (type?(String, true) failed)"]}})
        end
      end
    end

    context 'hash with array node' do
      subject do
        NxtSchema.new do |root|
          root.schema(:company) do |company|
            company.nodes(:employees) do |employees|
              employees.schema(:employee) do |employee|
                employee.requires(:first_name, :String)
                employee.requires(:last_name, :String)
              end
            end
          end
        end
      end

      context 'when the array node defines a single schema for items' do
        context 'when the value is not an array' do
          let(:schema) do
            { company: { employees: 'Andy & Rapha' } }
          end

          it do
            subject.apply(schema)

            expect(
              subject.validation_errors[:company][:employees][:itself]
            ).to eq(["\"Andy & Rapha\" violates constraints (type?(Array, \"Andy & Rapha\") failed)"])
          end
        end

        context 'when the value is an array' do
          context 'and the array contains items' do
            context 'and the items match the schema' do
              let(:schema) do
                {
                  company: {
                    employees: [
                      { first_name: 'Andy', last_name: 'Robecke' },
                      { first_name: 'Rapha', last_name: 'Kallensee'}
                    ]
                  }
                }
              end

              it do
                subject.apply(schema)
                expect(subject.validation_errors).to be_empty
                expect(subject.value_store).to eq(schema)
              end
            end

            context 'and items do not match the schema' do
              let(:schema) do
                { company: { employees: [{ first_name: 'Andy' }, { first_name: 'Rapha', last_name: 'Kallensee'} ] } }
              end

              it do
                subject.apply(schema)
                expect(subject.validation_errors).to eq(
                  :company=>{:employees=>{0=>{:employee=>{:itself=>["Required key :last_name is missing in {:first_name=>\"Andy\"}"]}}}}
                )
              end
            end
          end

          context 'but the array is empty' do
            let(:schema) do
              { company: { employees: [] } }
            end

            # TODO: This would also work with validations instead?
            it 'adds an error' do
              subject.apply(schema)
              expect(subject.validation_errors).to be_truthy
              expect(subject.validation_errors).to eq(:company=>{:employees=>{:itself=>["Array is not allowed to be empty"]}})
            end
          end
        end
      end

      context 'when the array node allows multiple schemas for items' do

      end
    end
  end
end
