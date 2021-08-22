RSpec.describe NxtSchema do
  subject { node.path }

  context 'hash with hash nodes' do
    let(:schema) do
      NxtSchema.schema(:company) do |company|
        company.node(:name, type: :String)
        company.node(:customers, type: :Integer)
        company.schema(:address) do |address|
          address.node(:street, type: :String)
          address.node(:street_number, type: :Integer)
          address.node(:zip_code, type: :Integer)
        end
      end
    end

    describe '#path' do
      let(:node) { schema[:address][:street] }

      it { expect(subject).to eq('company.address.street') }
    end
  end

  context 'hash with array of nodes' do
    let(:schema) do
      NxtSchema.schema(:person) do |person|
        person.node(:name, type: :String)
        person.collection(:houses) do |houses|
          houses.schema(:house) do |address|
            address.node(:street, type: :String)
            address.node(:street_number, type: :Integer)
            address.node(:zip_code, type: :Integer)
          end
        end
      end
    end

    describe '#path' do
      describe '#path' do
        let(:node) { schema[:houses][:house][:street] }

        it { expect(subject).to eq('person.houses.house.street') }
      end
    end
  end
end
