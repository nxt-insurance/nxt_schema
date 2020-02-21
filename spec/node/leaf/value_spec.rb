RSpec.describe NxtSchema::Node::Leaf do
  describe '#value' do
    context 'when there are schema errors' do
      subject do
        described_class.new(name: :leaf, type: :String, parent_node: nil).apply(84)
      end

      it do
        expect(subject.value).to eq(84)
        expect(subject.schema_errors).to eq(itself: ["84 violates constraints (type?(String, 84) failed)"])
      end
    end

    context 'when there are no schema errors' do
      context 'when the maybe criteria applies' do
        subject do
          described_class.new(name: :leaf, type: :String, parent_node: nil).maybe(84).apply(84)
        end

        it do
          expect(subject.value).to eq(84)
          expect(subject.schema_errors).to be_empty
        end
      end

      context 'when the maybe criteria does not apply' do
        subject do
          described_class.new(name: :leaf, type: :String, parent_node: nil).maybe(84).apply(25)
        end

        it do
          expect(subject.value).to eq(25)
          expect(subject.schema_errors).to eq(itself: ["25 violates constraints (type?(String, 25) failed)"])
        end
      end
    end
  end
end
