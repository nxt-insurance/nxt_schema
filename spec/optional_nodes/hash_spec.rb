RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'when nodes are optional' do
    let(:schema) do
      NxtSchema.hash(:person) do |person|
        person.node(:first_name, :String)
        person.node(:last_name, :String)
        person.hash(:address).optional do |address|
          address.node(:street, :String)
          address.node(:town, :String)
        end
      end
    end


    context 'and it is present' do
      let(:input) do
        {
          first_name: 'Hanna',
          last_name: 'Robecke',
          address: {
            street: 'Am Waeldchen 9',
            town: 'Kaiserslautern'
          }
        }
      end

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(input)
      end
    end

    context 'and it is not present' do
      let(:input) do
        {
          first_name: 'Hanna',
          last_name: 'Robecke'
        }
      end

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(input)
      end
    end
  end
end
