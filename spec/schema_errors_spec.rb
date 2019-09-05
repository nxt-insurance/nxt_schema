RSpec.describe NxtSchema do
  describe '#validate' do
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
          expect(subject).to_not be_valid
          expect(subject.errors).to eq('company' => ['Required key :industry is missing'])
        end
      end

      context 'when the value is of the wrong type' do
        let(:schema) do
          { company: { name: 'getsafe', industry: true } }
        end

        it do
          subject.apply(schema)
          expect(subject).to_not be_valid
          expect(subject.errors).to eq('company.industry' => ["Could not coerce 'true' into type: NxtSchema::Type::Strict::String"])
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
            expect(subject).to_not be_valid
            expect(subject.errors).to eq('company.employees' => ["Could not coerce 'Andy & Rapha' into type: NxtSchema::Type::Strict::Array"])
          end
        end

        context 'when the value is an array' do
          context 'and the array contains items' do
            context 'and the items match the schema' do
              let(:schema) do
                { company: { employees: [{ first_name: 'Andy', last_name: 'Robecke' }, { first_name: 'Rapha', last_name: 'Kallensee'} ] } }
              end

              it 'is valid' do
                subject.apply(schema)
                expect(subject).to be_valid
                expect(subject.errors).to be_empty
              end
            end

            context 'and items do not match the schema' do
              let(:schema) do
                { company: { employees: [{ first_name: 'Andy' }, { first_name: 'Rapha', last_name: 'Kallensee'} ] } }
              end

              it 'is not valid' do
                subject.apply(schema)
                binding.pry
                expect(subject).to_not be_valid
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
              expect(subject).to_not be_valid
              expect(subject.errors).to eq('company.employees' => ["Array is not allowed to be empty"])
            end
          end
        end
      end

      context 'when the array node allows multiple schemas for items' do

      end
    end
  end
end
