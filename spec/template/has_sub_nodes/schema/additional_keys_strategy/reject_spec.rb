RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  context 'when additional keys are rejected' do
    let(:schema) do
      NxtSchema.schema(:task, additional_keys: :reject) do |task|
        task.node(:name, :String)
        task.collection(:sub_tasks) do |sub_tasks|
          sub_tasks.schema(:sub_task) do |sub_task|
            sub_task.node(:name, :String)
            sub_task.node(:description, :String)
          end
        end
      end
    end

    let(:input) do
      {
        name: 'Do something',
        description: 'Will be rejected',
        sub_tasks: [
          { name: 'Do some more', description: 'do it carefully' },
          { name: 'Do some more', description: 'do it carefully', estimate: 'We do not do estimates' }
        ]
      }
    end

    it { expect(subject).to be_valid }

    it 'rejects the additional keys' do
      expect(subject.output).to eq(
        {
          name: "Do something",
          sub_tasks:
            [
              { name: "Do some more", description: "do it carefully" },
              { name: "Do some more", description: "do it carefully" }
            ]
        }
      )
    end
  end
end
