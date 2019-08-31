RSpec.describe NxtSchema do
  it "has a version number" do
    expect(NxtSchema::VERSION).not_to be nil
  end

  context 'when the schema is nested' do
    subject do
      NxtSchema.new do |schema|
        schema.node(:company, type: Hash) do |company|
          company.node(:name, type: String)
          company.node(:industry, type: String)

          company.node(:headquarter, type: Hash, optional: true, default: {}, allow: :empty?) do |headquarter|
            street_number_validator = lambda do |street_number, node|
              if headquarter[:street] == 'Langer Anger' && street_number <= 0
                node.add_error(street_number, 'Street number must be greater 0')
              end
            end

            headquarter.node(:street, type: String)
            headquarter.node(:street_number, type: Integer, validate: street_number_validator)
          end

          company.node(:employee_names, type: Array) do |collection|
            collection.node(:employee_name, type: Hash) do |employee_name|
              employee_name.node(:first_name, type: String)
              employee_name.node(:last_name, type: String)
            end
          end
        end
      end
    end

    it 'builds the schema' do
      # expect(subject[:company]).to be_a(NxtSchema::Nodes::HashNode)
      #
      # expect(subject[:company][:name]).to be_a(NxtSchema::Nodes::SimpleNode)
      # expect(subject[:company][:industry]).to be_a(NxtSchema::Nodes::SimpleNode)
      #
      # expect(subject[:company][:headquarter]).to be_a(NxtSchema::Nodes::HashNode)
      # expect(subject[:company][:headquarter][:street]).to be_a(NxtSchema::Nodes::SimpleNode)
      # expect(subject[:company][:headquarter][:street].type).to eq(String)
      # expect(subject[:company][:headquarter][:street_number]).to be_a(NxtSchema::Nodes::SimpleNode)
      # expect(subject[:company][:headquarter][:street_number].type).to eq(Integer)
      #
      # expect(subject[:company][:employee_names]).to be_a(NxtSchema::Nodes::ArrayNode)
      # expect(subject[:company][:employee_names].first).to be_a(NxtSchema::Nodes::HashNode)
      # expect(subject[:company][:employee_names].first[:first_name]).to be_a(NxtSchema::Nodes::SimpleNode)
      # expect(subject[:company][:employee_names].last[:last_name]).to be_a(NxtSchema::Nodes::SimpleNode)
    end

    describe '#validate' do
      context 'when there are no errors' do
        let(:schema) do
          {
            company: {
              name: 'getsafe',
              industry: 'insurance',
              headquarter: {
                street: 'Langer Anger',
                street_number: 6
              },
              employee_names: [
                { first_name: 'Raphael', last_name: 'Kallensee' },
                { first_name: 'Nils', last_name: 'Sommer' },
                { first_name: 'Lütfi', last_name: 'Demirci' }
              ]
            }
          }
        end

        it do
          subject.validate(schema)
          expect(subject.errors).to be_empty
        end
      end

      context 'when there are errors' do
        let(:schema) do
          {
            company: {
              name: 'getsafe',
              industry: 'insurance',
              headquarter: {
                street: 'Langer Anger',
                street_number: '6'
              },
              employee_names: [
                { first_name: 'Raphael', last_name: 'Kallensee' },
                { first_name: 'Nils' },
                { }
              ]
            }
          }
        end

        it do
          subject.validate(schema)
          expect(subject.errors['company.headquarter.street_number'].first.values.first).to be_a(NxtSchema::Nodes::Error)
          expect(subject.errors['company.employee_names.employee_name.last_name'].first.values).to all(be_a(NxtSchema::Nodes::Error))
          expect(subject.errors['company.employee_names.employee_name.first_name'].first.values).to all(be_a(NxtSchema::Nodes::Error))
        end
      end

      context 'with violation of custom validations' do
        let(:schema) do
          {
            company: {
              name: 'getsafe',
              industry: 'insurance',
              headquarter: {
                street: 'Langer Anger',
                street_number: 0
              },
              employee_names: [
                { first_name: 'Raphael', last_name: 'Kallensee' },
                { first_name: 'Nils' },
                { }
              ]
            }
          }
        end

        it do
          subject.validate(schema)
          binding.pry
        end
      end
    end
  end
end
