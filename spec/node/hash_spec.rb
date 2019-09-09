RSpec.describe NxtSchema::Node::Hash do
  describe '#apply' do
    subject do
      described_class.new(:company, nil, {}) do |company|
        company.requires(:street, :String)
        company.requires(:street_number, :Integer)
        company.requires(:value, :Integer)
        company.requires(:stocks_available, :Boolean)
        company.nodes(:employees) do |employees|
          employees.schema(:employee) do |employee|
            employee.requires(:first_name, :String)
            employee.requires(:last_name, :String)
            employee.nodes(:skills) do |skills|
              skills.requires(:skill, :String)
            end
          end
        end
      end
    end

    context 'when there are no errors' do
      let(:schema) do
        {
          street: 'Langer Anger',
          street_number: 6,
          value: 100_000_000,
          stocks_available: false,
          employees: [
            { first_name: 'Nils', last_name: 'Sommer', skills: ['ruby'] },
            { first_name: 'Lütfi', last_name: 'Demirci', skills: ['backend'] },
            { first_name: 'Rapha', last_name: 'Kallensee', skills: ['apis', 'jokes'] }
          ]
        }
      end

      it do
        subject.apply(schema)
        expect(subject.node_errors).to be_empty
        expect(subject.value_store).to eq(schema)
      end
    end

    context 'when there are errors' do
      let(:schema) do
        {
          street: 'Langer Anger',
          street_number: '6',
          value: 100_000_000,
          stocks_available: 'nope',
          employees: [
            { last_name: 'Sommer', skills: nil },
            { first_name: 'Lütfi', skills: [] },
            { first_name: 'Rapha', last_name: 3_000, skills: true },
            { first_name: 'Andreas', last_name: 'Robecke', skills: ['jokes'] }
          ]
        }
      end

      it do
        subject.apply(schema)
        expect(subject.node_errors).to eq(
          :street_number=>{:itself=>["Could not coerce '6' into type: NxtSchema::Type::Strict::Integer"]},
          :stocks_available=>{:itself=>["Could not coerce 'nope' into type: NxtSchema::Type::Strict::Boolean"]},
          :employees=>
            {0=>
              {:employee=>
                {:itself=>["Required key :first_name is missing in {:last_name=>\"Sommer\", :skills=>nil}"],
                :skills=>{:itself=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Array"]}}},
            1=>
              {:employee=>
                {:itself=>["Required key :last_name is missing in {:first_name=>\"Lütfi\", :skills=>[]}"], :skills=>{:itself=>["Array is not allowed to be empty"]}}},
            2=>
              {:employee=>
                {:last_name=>{:itself=>["Could not coerce '3000' into type: NxtSchema::Type::Strict::String"]},
                :skills=>{:itself=>["Could not coerce 'true' into type: NxtSchema::Type::Strict::Array"]}}}}
        )
      end
    end
  end

  describe '#maybe' do
    subject do
      described_class.new(:company, nil, maybe: :empty?) do |company|
        company.requires(:street, :String)
        company.requires(:street_number, :Integer)
        company.requires(:value, :Integer)
        company.requires(:stocks_available, :Boolean)
      end
    end

    it do
      subject.apply({})
      expect(subject.value_store).to eq({})
    end
  end
end
