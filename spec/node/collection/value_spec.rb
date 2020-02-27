RSpec.describe NxtSchema::Node::Collection do
  describe '#value' do
    context 'when there are schema errors' do
      subject do
        described_class.new(name: :params, parent_node: nil).apply(84)
      end

      it do
        expect(subject).to_not be_valid
        expect(subject.errors).to eq("params"=>["84 violates constraints (type?(Array, 84) failed)"])
      end
    end

    context 'when there are no schema errors' do
      context 'when the maybe criteria applies' do
        subject do
          described_class.new(name: :params, parent_node: nil).maybe(84).apply(84)
        end

        it do
          expect(subject).to be_valid
          expect(subject.value).to eq(84)
        end
      end

      context 'when the maybe criteria does not apply' do
        subject do
          described_class.new(name: :params, parent_node: nil).maybe(19).apply(84)
        end

        it do
          expect(subject).to_not be_valid
          expect(subject.errors).to eq("params"=>["84 violates constraints (type?(Array, 84) failed)"])
        end
      end
    end

    context 'default value' do
      context 'when no value was given' do
        context 'but a default value was given' do
          context 'and the maybe criteria applies' do
            subject do
              described_class.new(name: :leaf, parent_node: nil).maybe(84).default(84)
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
                described_class.new(name: :leaf, parent_node: nil).maybe(84).default([])
              end

              it do
                subject.apply(nil)
                expect(subject).to be_valid
                expect(subject.value).to eq([])
              end
            end

            context 'and the default value is of the wrong type' do
              subject do
                described_class.new(name: :leaf, parent_node: nil).maybe(19).default(84)
              end

              it do
                subject.apply(nil)
                expect(subject).to_not be_valid
                expect(subject.errors).to eq("leaf"=>["84 violates constraints (type?(Array, 84) failed)"])
              end
            end
          end
        end
      end

      context 'when a value was given' do
        context 'and a default value was given' do
          context 'and the maybe criteria applies' do

          end

          context 'and the maybe criteria does not apply' do

          end
        end
      end
    end
  end
end
