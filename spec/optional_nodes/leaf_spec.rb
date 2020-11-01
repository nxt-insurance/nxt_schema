RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'when nodes are optional' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.node(:first_name, :String)
        person.node(:last_name, :String)
        person.node(:phone, :String).optional
      end
    end


    context 'and it is present' do
      let(:input) do
        {
          first_name: 'Hanna',
          last_name: 'Robecke',
          phone: '017696426299'
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
