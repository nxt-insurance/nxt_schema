RSpec.describe NxtSchema do
  context 'optional keys' do
    context 'when keys in the schema are optional' do
      let(:email_validator) do
        lambda do |node, value|
          unless value.include?('@')
            node.add_error('Email is not valid')
          end
        end
      end

      subject do
        NxtSchema.root do |person|
          person.requires(:first_name, :String)
          person.optional(:last_name, :String)
          person.optional(:email, :String).validate(email_validator)
        end
      end


      context 'when the optional keys are not given' do
        let(:schema) do
          { first_name: 'Andy' }
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors?).to be_falsey
          expect(subject.value_store).to eq(schema)
        end
      end

      context 'when the optional keys are given' do
        context 'and validations are valid' do
          let(:schema) do
            { first_name: 'Andy', email: 'andreas@robecke.de' }
          end

          it do
            subject.apply(schema)
            expect(subject.validation_errors?).to be_falsey
            expect(subject.value_store).to eq(schema)
          end
        end

        context 'and validations fail' do
          let(:schema) do
            { first_name: 'Andy', email: 'invalid' }
          end

          it do
            subject.apply(schema)
            expect(subject.validation_errors).to be_truthy
            expect(subject.value_store).to eq(schema)
            expect(subject.validation_errors).to eq(:email=>{:itself=>["Email is not valid"]})
          end
        end
      end
    end

    context 'when keys in the schema are conditionally optional' do
      subject do
        NxtSchema.root do |company|
          company.nodes(:employees) do |employees|
            employees.schema(:employee) do |employee|
              employee.node(:name, :String)
              employee.node(:email, :String).optional ->(node) { node[:name] == 'Andy' }
            end
          end
        end
      end

      context 'when the node is required' do
        let(:schema) do
          {
            headquarter: {
              street: 'Langer Anger'
            },
            employees: [
              { name: 'Andy' },
              { name: 'Nils' },
              { name: 'Raphael', email: 'rapha@kallensee.de' }
            ]
          }
        end

        it do
          subject.apply(schema)
          expect(subject.errors).to eq("root.employees.1.employee"=>["Required key missing!"])
        end
      end
    end
  end
end
