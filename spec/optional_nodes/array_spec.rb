RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'when nodes are optional' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.collection(:skills).optional do |skills|
          skills.node(:skill, :String)
        end
      end
    end


    context 'and it is present' do
      let(:input) do
        { skills: ['Ruby', 'Javascript'] }
      end

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(input)
      end
    end

    context 'and it is not present' do
      let(:input) do
        { }
      end

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(input)
      end
    end
  end
end
