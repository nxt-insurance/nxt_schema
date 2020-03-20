# frozen_string_literal: true

RSpec.describe NxtSchema::Node::Leaf do
  context 'validations' do
    describe '#validate_with' do
      context 'without conditionals' do
        subject do
          node = described_class.new(name: :leaf, type: :Integer, parent_node: nil)

          node.validate_with do
            validator(:greater_than, 5) &&
              validator(:greater_than, 6) &&
              validator(:greater_than, 7)
          end

          node
        end

        context 'when the node is invalid' do
          it do
            subject.apply(4)
            expect(subject.errors).to eq('leaf' => ['4 must be greater than 5'])
          end

          it do
            subject.apply(6)
            expect(subject.errors).to eq('leaf' => ['6 must be greater than 6'])
          end

          it do
            subject.apply(7)
            expect(subject.errors).to eq('leaf' => ['7 must be greater than 7'])
          end
        end

        context 'when the node is valid' do
          it do
            subject.apply(8)
            expect(subject.errors).to be_empty
          end
        end
      end

      context 'with conditional' do
        subject do
          node = described_class.new(name: :leaf, type: :String, parent_node: nil)

          node.validate_with do
            unless value == 'skip validation'
              validator(:format, /\A\d+\z/) ||
                validator(:format, /\A[-]+\z/)
            end
          end

          node
        end

        context 'when the condition applies' do
          it do
            subject.apply('skip validation')
            expect(subject.errors).to be_empty
          end
        end

        context 'when the condition does not apply' do
          context 'when the pattern matches' do
            it do
              subject.apply('123')
              expect(subject.errors).to be_empty
            end

            it do
              subject.apply('---')
              expect(subject.errors).to be_empty
            end
          end

          context 'when the pattern does not match' do
            it do
              subject.apply('1-2-3')
              expect(subject.errors).to eq(
                'leaf' =>
                  [
                    '1-2-3 must match pattern (?-mix:\\A\\d+\\z)',
                    '1-2-3 must match pattern (?-mix:\\A[-]+\\z)'
                  ]
              )
            end
          end
        end
      end
    end

    describe '#validate' do
      subject do
        node = described_class.new(name: :leaf, type: :Integer, parent_node: nil)
        node.validate(:greater_than, 7)
        node
      end

      context 'when the node is valid' do
        it do
          subject.apply(8)
          expect(subject.errors).to be_empty
        end
      end

      context 'when the node is invalid' do
        it do
          subject.apply(7)
          expect(subject.errors).to eq('leaf' => ['7 must be greater than 7'])
        end
      end
    end
  end
end
