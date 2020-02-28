RSpec.describe NxtSchema::Node::Collection do
  describe '#apply' do
    subject do
      described_class.new(name: :test, parent_node: nil) do |node|
        node.requires(:item, :String)
      end
    end

    context 'when the nodes are all valid' do
      let(:schema) do
        %w[Andy Rapha Nils Lütfi]
      end

      it do
        subject.apply(schema)
        expect(subject.validation_errors).to be_empty
        expect(subject.value_store).to eq(schema)
      end
    end

    context 'when there are invalid nodes' do
      let(:schema) do
        ['Rapha', 'Nils', nil, 1, [], {}, false, true]
      end

      it do
        subject.apply(schema)
        expect(subject.validation_errors).to eq(
          2=>{:item=>{:itself=>["nil violates constraints (type?(String, nil) failed)"]}},
          3=>{:item=>{:itself=>["1 violates constraints (type?(String, 1) failed)"]}},
          4=>{:item=>{:itself=>["[] violates constraints (type?(String, []) failed)"]}},
          5=>{:item=>{:itself=>["{} violates constraints (type?(String, {}) failed)"]}},
          6=>{:item=>{:itself=>["false violates constraints (type?(String, false) failed)"]}},
          7=>{:item=>{:itself=>["true violates constraints (type?(String, true) failed)"]}}
        )
        expect(subject.value_store).to eq(schema)
      end
    end

    context 'an array of arrays' do
      subject do
        described_class.new(name: :parent, parent_node: nil) do |node|
          node.nodes(:children) do |children|
            children.requires(:child, :String)
          end
        end
      end

      let(:schema) do
        [
          ['Andy'], ['Rapha', 'Nils'], ['Lütfi'], [], [false]
        ]
      end

      it do
        subject.apply(schema)

        expect(subject.validation_errors).to eq(
          4=>{:children=>{0=>{:child=>{:itself=>["false violates constraints (type?(String, false) failed)"]}}}}
        )
        expect(subject.value_store).to eq(schema)
      end
    end

    context 'an array of arrays of hashes' do
      subject do
        described_class.new(name: :grand_parents, parent_node: nil) do |node|
          node.nodes(:parents) do |parents|
            parents.schema(:parent) do |parent|
              parent.requires(:first_name, :String)
              parent.requires(:last_name, :String)
            end
          end
        end
      end

      let(:schema) do
        [
          [
            { first_name: 'Lütfi', last_name: 'Demirci' },
            nil,
            true,
            false,
            [ ],
            { },
            { first_name: 'Nils' }
          ],
          [
            nil,
            1,
            '12.34'.to_d,
            [ ],
            { },
            { first_name: 'Rapha', last_name: 3_000 },
            { last_name: 'Sommer' }
          ]
        ]
      end

      it do
        subject.apply(schema)
        expect(subject.validation_errors).to eq(
          0=>
           {:parents=>
             {1=>{:parent=>{:itself=>["nil violates constraints (type?(Hash, nil) failed)"]}},
               2=>{:parent=>{:itself=>["true violates constraints (type?(Hash, true) failed)"]}},
               3=>{:parent=>{:itself=>["false violates constraints (type?(Hash, false) failed)"]}},
               4=>{:parent=>{:itself=>["[] violates constraints (type?(Hash, []) failed)"]}},
               5=>{:parent=>{:itself=>["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"]}},
               6=>{:parent=>{:itself=>["Required key :last_name is missing in {:first_name=>\"Nils\"}"]}}}},
          1=>
           {:parents=>
             {0=>{:parent=>{:itself=>["nil violates constraints (type?(Hash, nil) failed)"]}},
               1=>{:parent=>{:itself=>["1 violates constraints (type?(Hash, 1) failed)"]}},
               2=>{:parent=>{:itself=>["0.1234e2 violates constraints (type?(Hash, 0.1234e2) failed)"]}},
               3=>{:parent=>{:itself=>["[] violates constraints (type?(Hash, []) failed)"]}},
               4=>{:parent=>{:itself=>["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"]}},
               5=>{:parent=>{:last_name=>{:itself=>["3000 violates constraints (type?(String, 3000) failed)"]}}},
               6=>{:parent=>{:itself=>["Required key :first_name is missing in {:last_name=>\"Sommer\"}"]}}}}
        )

        expect(subject.value_store).to eq(schema)
      end
    end
  end

  describe '#validations' do
    let(:validate_max_2_items) do
      Proc.new do |node, array|
        if array.size > 2
          node.add_error('Can only contain two items')
        end
      end
    end

    subject do
      described_class.new(name: :test, parent_node: nil).validate(validate_max_2_items) do |node|
        node.requires(:item, :String)
      end
    end

    context 'when the nodes are all valid' do
      let(:schema) do
        %w[Andy Rapha Nils Lütfi]
      end

      it 'contains only the custom error' do
        subject.apply(schema)
        expect(subject.validation_errors).to eq(:itself=>["Can only contain two items"])
      end
    end

    context 'when there are invalid nodes' do
      let(:schema) do
        ['Rapha', 'Nils', nil, 1, [], {}, false, true]
      end

      it 'contains the custom errors and node errors' do
        subject.apply(schema)
        expect(subject.validation_errors).to eq(
          :itself=>["Can only contain two items"],
          2=>{:item=>{:itself=>["nil violates constraints (type?(String, nil) failed)"]}},
          3=>{:item=>{:itself=>["1 violates constraints (type?(String, 1) failed)"]}},
          4=>{:item=>{:itself=>["[] violates constraints (type?(String, []) failed)"]}},
          5=>{:item=>{:itself=>["{} violates constraints (type?(String, {}) failed)"]}},
          6=>{:item=>{:itself=>["false violates constraints (type?(String, false) failed)"]}},
          7=>{:item=>{:itself=>["true violates constraints (type?(String, true) failed)"]}}
        )
      end
    end
  end

  describe '#maybe' do
    context 'when the value maybe empty' do
      subject do
        described_class.new(name: :test, parent_node: nil, maybe: []) do |node|
          node.requires(:item, :String)
        end
      end

      it do
        subject.apply([])
        expect(subject.validation_errors?).to be_falsey
        expect(subject.value).to eq([])
      end
    end

    context 'when the value maybe nil' do
      subject do
        described_class.new(name: :test, parent_node: nil).maybe(nil) do |node|
          node.requires(:item, :String)
        end
      end

      it do
        subject.apply(nil)
        expect(subject.validation_errors?).to be_falsey
        expect(subject.value).to eq(nil)
      end
    end
  end

  describe '#default' do

  end

  describe 'with multiple schemas in an array node' do
    context 'with multiple hash schemas' do
      subject do
        NxtSchema.nodes(:furniture) do
          schema(:table) do
            requires(:height, :Integer)
          end
          schema(:cupboard) do
            requires(:doors, :Integer)
          end
          schema(:couch) do
            requires(:seats, :Integer)
          end
        end
      end

      let(:schema) do
        [
          { height: 100 },
          { height: 90 },
          { doors: 3 },
          { doors: 5 },
          { seats: 3 },
          { seats: 4 },
          { amount: 12 },
          { other: 12 },
          { },
          nil
        ]
      end

      it 'merges the errors of all nodes' do
        subject.apply(schema)

        expect(subject.errors).to eq(
          "furniture.6.table"=>["Required key :height is missing in {:amount=>12}"],
          "furniture.6.cupboard"=>["Required key :doors is missing in {:amount=>12}"],
          "furniture.6.couch"=>["Required key :seats is missing in {:amount=>12}"],
          "furniture.7.table"=>["Required key :height is missing in {:other=>12}"],
          "furniture.7.cupboard"=>["Required key :doors is missing in {:other=>12}"],
          "furniture.7.couch"=>["Required key :seats is missing in {:other=>12}"],
          "furniture.8.table"=>["Required key :height is missing in {}"],
          "furniture.8.cupboard"=>["Required key :doors is missing in {}"],
          "furniture.8.couch"=>["Required key :seats is missing in {}"],
          "furniture.9.table"=>["nil violates constraints (type?(Hash, nil) failed)"],
          "furniture.9.cupboard"=>["nil violates constraints (type?(Hash, nil) failed)"],
          "furniture.9.couch"=>["nil violates constraints (type?(Hash, nil) failed)"]
        )
      end
    end

    context 'with different leaf nodes' do
      subject do
        NxtSchema.roots(:diverse) do
          node(:name, :String)
          node(:age, :Integer)
        end
      end

      let(:schema) do
        [17, 30, 30, 'Nils', 'Rapha', 'Andy', nil, false, {}, []]
      end

      it do
        subject.apply(schema)

        expect(subject.errors).to eq(
          "diverse.6.name"=>["nil violates constraints (type?(String, nil) failed)"],
          "diverse.6.age"=>["nil violates constraints (type?(Integer, nil) failed)"],
          "diverse.7.name"=>["false violates constraints (type?(String, false) failed)"],
          "diverse.7.age"=>["false violates constraints (type?(Integer, false) failed)"],
          "diverse.8.name"=>["{} violates constraints (type?(String, {}) failed)"],
          "diverse.8.age"=>["{} violates constraints (type?(Integer, {}) failed)"],
          "diverse.9.name"=>["[] violates constraints (type?(String, []) failed)"],
          "diverse.9.age"=>["[] violates constraints (type?(Integer, []) failed)"]
        )
      end
    end
  end
end
