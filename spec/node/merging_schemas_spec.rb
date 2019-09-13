RSpec.describe NxtSchema do
  context 'adding an array node into a hash' do
    let(:people_node) do
      NxtSchema.nodes do
        schema(:person) do
          requires(:first_name, :String)
          requires(:last_name, :String)
        end
      end
    end

    subject do
      people = people_node
      NxtSchema.root(:company) do
        requires(:people, people)
        requires(:value, :Integer)
        requires(:street, :String)
        requires(:street_number, :Integer)
      end
    end

    let(:schema) do
      {
        people: [
          { first_name: 'Andy', last_name: 'Robecke' },
          { first_name: 'Nils', last_name: nil },
          { first_name: 'Lütfi', last_name: false },
          { first_name: 'Rapha', last_name: 'Kallensee' }
        ],
        value: 10_000_000,
        street: 'Langer Anger',
        street_number: 6
      }
    end

    it 'merges the schemas' do
      subject.apply(schema)
      expect(subject.errors).to eq(
        "company.people.1.person.last_name"=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::String"],
        "company.people.2.person.last_name"=>["Could not coerce 'false' into type: NxtSchema::Type::Strict::String"]
      )
    end
  end

  context 'adding a hash into hash' do
    let(:address_node) do
      NxtSchema.root do
        requires(:street, :String)
        requires(:street_number, :String)
      end
    end

    subject do
      address = address_node
      NxtSchema.root(:person) do
        requires(:first_name, :String)
        requires(:last_name, :String)
        requires(:address, address)
      end
    end

    let(:schema) do
      {
        first_name: 'Andy',
        last_name: 'Superman',
        address: {
          street: 'Feldbergstrasse',
          street_number: 'Somewhere only we know'
        }
      }
    end

    it 'merges the schemas' do
      subject.apply(schema)
      expect(subject.errors).to be_empty
      expect(subject.value).to eq(schema)
    end
  end

  context 'adding a hash into an array node' do
    let(:person_node) do
      NxtSchema.node do
        requires(:first_name, :String)
        optional(:last_name, :String)
      end
    end

    subject do
      person = person_node

      NxtSchema.nodes do
        node(:person, person)
      end
    end

    let(:schema) do
      [
        { first_name: 'Andy' },
        { first_name: 'Hanna' },
        { first_name: 'Nils', last_name: 'Sommer' },
        { first_name: 'Rapha', last_name: 'Kallensee' },
        { },
        nil
      ]
    end

    it 'merges the schemas' do
      subject.apply(schema)
      expect(subject.errors).to eq(
        "roots.4.person"=>["Required key :first_name is missing in {}"],
        "roots.5.person"=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Hash"]
      )
    end
  end

  context 'adding an array into an array' do

  end
end
