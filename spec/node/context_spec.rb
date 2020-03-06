RSpec.describe NxtSchema do
  describe '#context' do
    subject do
      described_class.params do
        schema(:user) do
          required(:first_name, :String)
          required(:last_name, :String)
          node(:password, :String).optional ->(node) { node.context != 'new' }

          nodes(:skills) do
            requires(:skill, NxtSchema::Types::SymbolizedEnums[*%i[run swim jump fly]])
          end
        end
      end
    end

    let(:values) do
      {
        'user' => {
          'first_name' => 'Nils',
          'last_name' => 'Winter',
          'skills' => ['run', 'jump'],
          'password' => 'Darmstadt'
        }
      }
    end

    it 'assigns the context to all nodes' do
      subject.apply(values, context: 'new')
      expect(subject.all_nodes.values.map(&:context)).to all(eq('new'))
      expect(subject).to be_valid
      expect(subject.value).to eq(
        user: {
          first_name: "Nils",
          last_name: "Winter",
          password: "Darmstadt",
          skills: [:run, :jump]
        }
      )
    end
  end
end
