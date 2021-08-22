RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  context 'when additional keys are restricted' do
    let(:schema) do
      NxtSchema.schema(:task, additional_keys: :restrict) do |task|
        task.node(:name, type: :String)
        task.collection(:sub_tasks) do |sub_tasks|
          sub_tasks.schema(:sub_task) do |sub_task|
            sub_task.node(:name, type: :String)
            sub_task.node(:description, type: :String)
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

    it 'adds the correct errors' do
      expect(subject.errors).to eq(
        "task"=>["Additional keys are not allowed: [:description]"],
        "task.sub_tasks.sub_task[1]"=>["Additional keys are not allowed: [:estimate]"]
      )

    end
  end
end
