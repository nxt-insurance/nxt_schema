RSpec.describe NxtSchema::Node::Schema do
  describe '#apply' do
    subject do
      described_class.new(name: :company, parent_node: nil) do |company|
        company.requires(:street, :String)
        company.requires(:street_number, :Integer)
        company.requires(:value, :Integer)
        company.requires(:stocks_available, :Bool)
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
        expect(subject.validation_errors).to be_empty
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

        expect(subject.validation_errors).to eq(
          :street_number=>{:itself=>["\"6\" violates constraints (type?(Integer, \"6\") failed)"]},
          :stocks_available=>{:itself=>["\"nope\" violates constraints (type?(FalseClass, \"nope\") failed)"]},
          :employees=>
            {
              0=>{
                :employee=>{
                  :itself=>["Required key :first_name is missing"],
                  :skills=>{:itself=>["nil violates constraints (type?(Array, nil) failed)"]}
                }
              },
              1=>{
                :employee=>{
                  :itself=>["Required key :last_name is missing"]
                }
              },
              2=>{
                :employee=>{
                  :last_name=>{:itself=>["3000 violates constraints (type?(String, 3000) failed)"]},
                  :skills=>{:itself=>["true violates constraints (type?(Array, true) failed)"]}
                }
              }
            }
        )
      end
    end
  end

  describe '#maybe' do
    context 'when the value maybe empty' do
      subject do
        described_class.new(name: :company, parent_node: nil, maybe: :empty?) do |company|
          company.requires(:street, :String)
          company.requires(:street_number, :Integer)
          company.requires(:value, :Integer)
          company.requires(:stocks_available, :Bool)
        end
      end

      it do
        subject.apply({})
        expect(subject.value_store).to eq({})
      end
    end

    context 'when the value maybe nil' do
      subject do
        described_class.new(name: :company, parent_node: nil, maybe: nil) do |company|
          company.requires(:street, :String)
          company.requires(:street_number, :Integer)
          company.requires(:value, :Integer)
          company.requires(:stocks_available, :Bool)
        end
      end

      it do
        subject.apply(nil)
        expect(subject.value_store).to eq(nil)
      end
    end

    context 'when the value maybe is a proc' do
      subject do
        described_class.new(name: :company, parent_node: nil, maybe: ->(value) { value == {} }) do |company|
          company.requires(:street, :String)
          company.requires(:street_number, :Integer)
          company.requires(:value, :Integer)
          company.requires(:stocks_available, :Bool)
        end
      end

      it do
        subject.apply({})
        expect(subject.value_store).to eq({})
      end
    end
  end

  describe '#default' do

  end

  describe '#validations' do

  end
end
