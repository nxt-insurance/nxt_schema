RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'when a collection node is optional' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.collection(:skills, optional: true) do |skills|
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

  context 'when a node within a collection is optional' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.collection(:skills) do |skills|
          skills.optional(:skill, :String)
        end
      end
    end

    context 'and the node is not given' do
      let(:input) do
        { skills: [] }
      end

      it do
        expect(subject).to be_valid
      end
    end
  end
end
