RSpec.describe NxtSchema do
  describe '#validate' do
    context 'hash with leaf nodes' do
      subject do
        NxtSchema.new do |root|
          root.schema(:company) do |company|
            company.requires(:name, :String)
            company.requires(:industry, :String)
          end
        end
      end

      context 'when a key is missing' do
        let(:schema) do
          { company: { name: 'getsafe' } }
        end

        it do
          subject.apply(schema)
          expect(subject).to_not be_valid
          expect(subject.node_errors).to eq(
            {
              company: {
                industry: ['']
              }
            }
          )
        end
      end
    end
  end
end
