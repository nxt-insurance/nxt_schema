RSpec.describe NxtSchema do
  describe '#apply' do
    context 'array with leaf nodes' do
      subject do
        NxtSchema.root do |root|
          root.nodes(:company) do |company|
            company
          end
        end
      end
    end

    context 'hash with leaf nodes' do
      subject do
        NxtSchema.root do |root|
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
        NxtSchema.root do |root|
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
        end
      end

      context 'when the array node allows multiple schemas for items' do
        subject do
          NxtSchema.root do |root|
            root.schema(:company) do |company|
              company.nodes(:workers) do |workers|
                workers.schema(:employee) do |employee|
                  employee.requires(:first_name, :String)
                  employee.requires(:last_name, :String)
                end

                workers.schema(:boss) do |boss|
                  boss.requires(:title, :String)
                  boss.requires(:last_name, :String)
                end
              end
            end
          end
        end

        context 'when there are invalid nodes' do
          let(:schema) do
            {
              company: {
                workers: [
                  { first_name: 'Andy', last_name: 'Robecke' },
                  { first_name: 'Rapha', last_name: 'Kallensee' },
                  { title: 'CTO', last_name: 'Blaesing' },
                  { title: 'CEO', last_name: 'Wienz' },
                  { title: nil },
                  { },
                  'Lütfi'
                ]
              }
            }
          end

          it do
            subject.apply(schema)

            expect(subject.errors).to eq(
              "root.company.workers.4.employee"=>["Required key :first_name is missing in {:title=>nil}", "Required key :last_name is missing in {:title=>nil}"],
              "root.company.workers.4.boss"=>["Required key :last_name is missing in {:title=>nil}"],
              "root.company.workers.4.boss.title"=>["nil violates constraints (type?(String, nil) failed)"],
              "root.company.workers.5.employee"=>["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"],
              "root.company.workers.5.boss"=>["Required key :title is missing in {}", "Required key :last_name is missing in {}"],
              "root.company.workers.6.employee"=>["\"Lütfi\" violates constraints (type?(Hash, \"Lütfi\") failed)"],
              "root.company.workers.6.boss"=>["\"Lütfi\" violates constraints (type?(Hash, \"Lütfi\") failed)"]
            )
          end
        end

        context 'when all nodes are valid' do
          let(:schema) do
            {
              company: {
                workers: [
                  { first_name: 'Andy', last_name: 'Robecke' },
                  { first_name: 'Rapha', last_name: 'Kallensee' },
                  { title: 'CTO', last_name: 'Blaesing' },
                  { title: 'CEO', last_name: 'Wienz' }
                ]
              }
            }
          end

          it do
            subject.apply(schema)
            expect(subject).to be_valid
            expect(subject.errors).to be_empty
            expect(subject.value_store).to eq(schema)
          end
        end
      end
    end
  end
end
