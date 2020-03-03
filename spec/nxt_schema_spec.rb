RSpec.describe NxtSchema do
  it "has a version number" do
    expect(NxtSchema::VERSION).not_to be nil
  end

  context 'when the schema is nested' do
    # NxtSchema.register_type(:int)
    # NxtSchema.register_validator(:gte) do |value, node|
    #   if value < expected
    #     node.add_error(value, 'Must be greater #{expected}')
    #   end
    # end

    subject do
      NxtSchema.root(:company) do |company|
        company.requires(:name, :String)
        company.requires(:industry, :String)

        company.optional(:headquarter, :Schema).maybe(nil).default({}) do |headquarter|
          street_number_validator = lambda do |node, street_number|
            if headquarter[:street] == 'Langer Anger' && street_number <= 0
              node.add_error('Street number must be greater 0')
            end
          end

          headquarter.node(:street, :String)
          headquarter.node(:street_number, :Integer, validate: street_number_validator) # validator(:gte, -> { DateTime.current })
        end

        company.nodes(:employee_names) do |nodes|
          nodes.node(:employee_name_underscore, :Schema) do |employee_name|
            employee_name.node(:first_name, :String)
            employee_name.node(:last_name, :String)
          end

          nodes.schema(:employee_name) do |employee_name|
            employee_name.node(:firstname, :String)
            employee_name.node(:lastname, :String)
          end
        end
      end
    end

    it 'builds the schema' do
      # expect(subject[:company]).to be_a(NxtSchema::Node::HashNode)
      #
      # expect(subject[:company][:name]).to be_a(NxtSchema::Node::SimpleNode)
      # expect(subject[:company][:industry]).to be_a(NxtSchema::Node::SimpleNode)
      #
      # expect(subject[:company][:headquarter]).to be_a(NxtSchema::Node::HashNode)
      # expect(subject[:company][:headquarter][:street]).to be_a(NxtSchema::Node::SimpleNode)
      # expect(subject[:company][:headquarter][:street].type).to eq(String)
      # expect(subject[:company][:headquarter][:street_number]).to be_a(NxtSchema::Node::SimpleNode)
      # expect(subject[:company][:headquarter][:street_number].type).to eq(Integer)
      #
      # expect(subject[:company][:employee_names]).to be_a(NxtSchema::Node::ArrayNode)
      # expect(subject[:company][:employee_names].first).to be_a(NxtSchema::Node::HashNode)
      # expect(subject[:company][:employee_names].first[:first_name]).to be_a(NxtSchema::Node::SimpleNode)
      # expect(subject[:company][:employee_names].last[:last_name]).to be_a(NxtSchema::Node::SimpleNode)
    end

    describe '#validate' do
      context 'when there are no errors' do
        let(:schema) do
          {
            name: 'getsafe',
            industry: 'insurance',
            headquarter: {
              street: 'Langer Anger',
              street_number: 6
            },
            employee_names: [
              { firstname: 'Raphael', lastname: 'Kallensee' },
              { first_name: 'Raphael', last_name: 'Kallensee' },
              { first_name: 'Nils', last_name: 'Sommer' },
              { first_name: 'Lütfi', last_name: 'Demirci' }
            ]
          }
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors?).to be_falsey
          expect(subject.validation_errors).to be_empty
          expect(subject.value_store).to eq(schema)
        end
      end

      context 'when there are errors' do
        let(:schema) do
          {
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
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors?).to be_truthy

          expect(subject.validation_errors).to eq(
            :headquarter => {
              :street_number => {
                :itself => ["\"6\" violates constraints (type?(Integer, \"6\") failed)"]
              }
            },
            :employee_names => {
              1 => {
                :employee_name_underscore => { :itself => ["Required key :last_name is missing in {:first_name=>\"Nils\"}"] },
                :employee_name => { :itself => ["Required key :firstname is missing in {:first_name=>\"Nils\"}", "Required key :lastname is missing in {:first_name=>\"Nils\"}"] } },
              2 => {
                :employee_name_underscore => { :itself => ["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"] },
                :employee_name => { :itself => ["Required key :firstname is missing in {}", "Required key :lastname is missing in {}"] }
              }
            }
           )
        end
      end

      context 'with violation of custom validations' do
        let(:schema) do
          {
            name: 'getsafe',
            industry: 'insurance',
            headquarter: {
              street: 'Langer Anger',
              street_number: 0
            },
            employee_names: [
              { firstname: 'Raphael', lastname: 'Kallensee' },
              { first_name: 'Nils' },
              { }
            ]
          }
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors).to eq(
           :headquarter=>{:street_number=>{:itself=>["Street number must be greater 0"]}},
           :employee_names=>
             {1=>
                {:employee_name_underscore=>{:itself=>["Required key :last_name is missing in {:first_name=>\"Nils\"}"]},
                 :employee_name=>
                   {:itself=>["Required key :firstname is missing in {:first_name=>\"Nils\"}", "Required key :lastname is missing in {:first_name=>\"Nils\"}"]}},
              2=>
                {:employee_name_underscore=>{:itself=>["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"]},
                 :employee_name=>{:itself=>["Required key :firstname is missing in {}", "Required key :lastname is missing in {}"]}}}
          )
        end
      end
    end
  end

  context 'when an anonymous schema is nested' do
    subject do
      NxtSchema.root(:company) do
        requires(:name, :String)
        requires(:industry, :String)

        optional(:headquarter, :Schema, default: {}, maybe: nil) do |headquarter|
          street_number_validator = lambda do |node, street_number|
            if headquarter[:street] == 'Langer Anger' && street_number <= 0
              node.add_error('Street number must be greater 0')
            end
          end

          headquarter.node(:street, :String)
          headquarter.node(:street_number, :Integer, validate: street_number_validator)
        end

        nodes(:employee_names) do
          schema(:employee_name_underscore) do
            node(:first_name, :String)
            node(:last_name, :String)
          end

          schema(:employee_name) do
            node(:firstname, :String)
            node(:lastname, :String)
          end
        end
      end
    end

    describe '#validate' do
      context 'when there are no errors' do
        let(:schema) do
          {
            name: 'getsafe',
            industry: 'insurance',
            headquarter: {
              street: 'Langer Anger',
              street_number: 6
            },
            employee_names: [
              { firstname: 'Raphael', lastname: 'Kallensee' },
              { first_name: 'Raphael', last_name: 'Kallensee' },
              { first_name: 'Nils', last_name: 'Sommer' },
              { first_name: 'Lütfi', last_name: 'Demirci' }
            ]
          }
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors?).to be_falsey
          expect(subject.validation_errors).to be_empty
          expect(subject.value_store).to eq(schema)
        end
      end

      context 'when there are errors' do
        let(:schema) do
          {
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
        end

        it do
          subject.apply(schema)

          expect(subject.validation_errors?).to be_truthy
          expect(subject.validation_errors).to eq(
            :headquarter => {
              :street_number => { :itself => ["\"6\" violates constraints (type?(Integer, \"6\") failed)"] }
            },
            :employee_names => {
              1 => {
                :employee_name_underscore => { :itself => ["Required key :last_name is missing in {:first_name=>\"Nils\"}"] },
                :employee_name => { :itself => ["Required key :firstname is missing in {:first_name=>\"Nils\"}", "Required key :lastname is missing in {:first_name=>\"Nils\"}"] }
              },
              2 => {
                :employee_name_underscore => { :itself => ["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"] },
                :employee_name => { :itself => ["Required key :firstname is missing in {}", "Required key :lastname is missing in {}"] }
              }
            }
          )
        end
      end

      context 'with violation of custom validations' do
        let(:schema) do
          {
            name: 'getsafe',
            industry: 'insurance',
            headquarter: {
              street: 'Langer Anger',
              street_number: 0
            },
            employee_names: [
              { firstname: 'Raphael', lastname: 'Kallensee' },
              { first_name: 'Nils' },
              { }
            ]
          }
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors).to eq(
            :headquarter=>{:street_number=>{:itself=>["Street number must be greater 0"]}},
            :employee_names=>
              {1=>
                  {:employee_name_underscore=>{:itself=>["Required key :last_name is missing in {:first_name=>\"Nils\"}"]},
                  :employee_name=>
                    {:itself=>["Required key :firstname is missing in {:first_name=>\"Nils\"}", "Required key :lastname is missing in {:first_name=>\"Nils\"}"]}},
                2=>
                  {:employee_name_underscore=>{:itself=>["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"]},
                  :employee_name=>{:itself=>["Required key :firstname is missing in {}", "Required key :lastname is missing in {}"]}}}
          )
        end
      end
    end
  end
end
