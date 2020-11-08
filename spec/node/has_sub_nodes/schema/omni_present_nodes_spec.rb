RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'with present nodes' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.omnipresent(:first_name, :String)
        person.omnipresent(:last_name, :String)
      end
    end


    context 'but the node is given already' do
      let(:input) do
        { first_name: 'Albert', last_name: 'Einstein' }
      end

      it { expect(subject).to be_valid }

      it { expect(subject.output).to eq(input) }
    end

    context 'and it is not present' do
      let(:input) { {} }

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to match(
          first_name: instance_of(NxtSchema::MissingInput),
          last_name: instance_of(NxtSchema::MissingInput)
        )
      end
    end
  end
end
