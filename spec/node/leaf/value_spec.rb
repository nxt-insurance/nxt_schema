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

    context 'default value' do
      context 'when no value was given' do
        context 'but a default value was given' do
          context 'and the maybe criteria applies' do
            subject do
              described_class.new(name: :leaf, type: :String, parent_node: nil).maybe(84).default(84)
            end

            it do
              subject.apply(nil)
              expect(subject).to be_valid
              expect(subject.value).to eq(84)
            end
          end

          context 'and the maybe criteria does not apply' do
            context 'but the default value is of the correct type' do
              subject do
                described_class.new(name: :leaf, type: :String, parent_node: nil).maybe(84).default('test')
              end

              it do
                subject.apply(nil)
                expect(subject).to be_valid
                expect(subject.value).to eq('test')
              end
            end

            context 'and the default value is of the wrong type' do
              subject do
                described_class.new(name: :leaf, type: :String, parent_node: nil).maybe(19).default(84)
              end

              it do
                subject.apply(nil)
                expect(subject).not_to be_valid
                expect(subject.errors).to eq("leaf"=>["84 violates constraints (type?(String, 84) failed)"])
              end
            end
          end
        end
      end

      context 'when a value was given' do
        context 'and a default value was given' do
          context 'and the maybe criteria applies' do
            subject do
              described_class.new(name: :leaf, type: :String, parent_node: nil).maybe(nil).default(84)
            end

            it do
              subject.apply(nil)
              expect(subject).to be_valid
              expect(subject.value).to eq(nil)
            end
          end

          context 'and the maybe criteria does not apply' do
            subject do
              described_class.new(name: :leaf, type: :String, parent_node: nil).maybe('').default(84)
            end

            it do
              subject.apply('test')
              expect(subject).to be_valid
              expect(subject.value).to eq('test')
            end
          end
        end
      end
    end
  end
end
