RSpec.describe NxtSchema do
  subject do
    schema.apply(input)
  end

  context 'when additional keys are allowed' do
    let(:schema) do
      NxtSchema.schema(:task, additional_keys: :allow, type_system: NxtSchema::Types::Coercible) do |task|
        task.node(:name, :String)
        task.collection(:sub_tasks) do |sub_tasks|
          sub_tasks.schema(:sub_task) do |sub_task|
            sub_task.node(:name, :String)
            sub_task.node(:id, :Integer)
          end
        end
      end
    end

    let(:input) do
      {
        name: 'Do something',
        description: 'Will not be rejected',
        sub_tasks: [
          { name: 'Do some more', id: '1' },
          { name: 'Do some more', id: '2', estimate: '12 weeks' }
        ],
        meta: 'Can be anything'
      }
    end

    it { expect(subject).to be_valid }

    it 'returns the correct output' do
      expect(subject.output).to eq(
        {
          name: 'Do something',
          description: 'Will not be rejected',
          sub_tasks: [
            { name: 'Do some more', id: 1 },
            { name: 'Do some more', id: 2, estimate: '12 weeks' }
          ],
          meta: 'Can be anything'
        }
      )
    end
  end
end
