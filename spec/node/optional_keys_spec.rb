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
          person.optional(:email, :String, validate: email_validator)
        end
      end


      context 'when the optional keys are not given' do
        let(:schema) do
          { first_name: 'Andy' }
        end

        it do
          subject.apply(schema)
          expect(subject).to be_valid
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
            expect(subject).to be_valid
            expect(subject.value_store).to eq(schema)
          end
        end

        context 'and validations fail' do
          let(:schema) do
            { first_name: 'Andy', email: 'invalid' }
          end

          it do
            subject.apply(schema)
            expect(subject).to_not be_valid
            expect(subject.value_store).to eq(schema)
            expect(subject.node_errors).to eq(:email=>{:itself=>["Email is not valid"]})
          end
        end
      end
    end

    context 'when keys in the schema are conditionally optional' do
      subject do
        NxtSchema.root do |person|
          person.requires(:first_name, :String)
          person.requires(:last_name, :String)
        end
      end
    end
  end
end
