RSpec.describe NxtSchema::Node do
  context 'meta attr accessor' do
    subject do
      NxtSchema.root(:company) do
        requires(:name, :String).meta('this is always broken').validate ->(node) { node.add_error(node.meta) }
        requires(:street, :String)
        requires(:street_number, :Integer)
      end
    end

    let(:values) do
      {
        name: 'getsafe',
        street: 'Langer Anger',
        street_number: 7
      }
    end

    it 'is possible to add meta data to each key' do
      subject.apply(values)
      expect(subject).to_not be_valid
    end
  end

  context 'custom methods' do
    subject do
      NxtSchema.root(:company) do
        define_singleton_method :error_messages do |key|
          {
            name: 'this is always broken'
          }.with_indifferent_access.fetch(key)
        end

        requires(:name, :String).validate ->(node) { node.add_error(node.parent.error_messages(node.name)) }
        requires(:street, :String)
        requires(:street_number, :Integer)
      end
    end

    let(:values) do
      {
        name: 'getsafe',
        street: 'Langer Anger',
        street_number: 7
      }
    end

    it 'is possible to add custom methods to a node' do
      subject.apply(values)
      expect(subject).to_not be_valid
    end
  end
end

