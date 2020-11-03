RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'when some nodes are optional' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.node(:first_name, :String)
        person.node(:last_name, :String)
        person.schema(:address, optional: true) do |address|
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

  context 'when all nodes within a schema are optional' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.optional(:first_name, :String)
        person.optional(:last_name, :String)
        person.schema(:address, optional: true) do |address|
          address.node(:street, :String)
          address.node(:town, :String)
        end
      end
    end

    context 'and some nodes are given' do
      let(:input) do
        {
          first_name: 'Andy',
          schema: { street: 'Am Waeldchen 9', town: 'Kaiserslautern' }
        }
      end

      it { expect(subject).to be_valid }
    end

    context 'and an empty hash is given' do
      let(:input) { {} }

      it { expect(subject).to be_valid }
    end
  end
end
