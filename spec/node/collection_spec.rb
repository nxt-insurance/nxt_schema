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
          2=>{:item=>{:itself=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::String"]}},
          3=>{:item=>{:itself=>["Could not coerce '1' into type: NxtSchema::Type::Strict::String"]}},
          4=>{:item=>{:itself=>["Could not coerce '[]' into type: NxtSchema::Type::Strict::String"]}},
          5=>{:item=>{:itself=>["Could not coerce '{}' into type: NxtSchema::Type::Strict::String"]}},
          6=>{:item=>{:itself=>["Could not coerce 'false' into type: NxtSchema::Type::Strict::String"]}},
          7=>{:item=>{:itself=>["Could not coerce 'true' into type: NxtSchema::Type::Strict::String"]}}
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
          3=>{:children=>{:itself=>["Array is not allowed to be empty"]}},
          4=>{:children=>{0=>{:child=>{:itself=>["Could not coerce 'false' into type: NxtSchema::Type::Strict::String"]}}}}
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
              {1=>{:parent=>{:itself=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Hash"]}},
               2=>{:parent=>{:itself=>["Could not coerce 'true' into type: NxtSchema::Type::Strict::Hash"]}},
               3=>{:parent=>{:itself=>["Could not coerce 'false' into type: NxtSchema::Type::Strict::Hash"]}},
               4=>{:parent=>{:itself=>["Could not coerce '[]' into type: NxtSchema::Type::Strict::Hash"]}},
               5=>{:parent=>{:itself=>["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"]}},
               6=>{:parent=>{:itself=>["Required key :last_name is missing in {:first_name=>\"Nils\"}"]}}}},
          1=>
           {:parents=>
              {0=>{:parent=>{:itself=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Hash"]}},
               1=>{:parent=>{:itself=>["Could not coerce '1' into type: NxtSchema::Type::Strict::Hash"]}},
               2=>{:parent=>{:itself=>["Could not coerce '12.34' into type: NxtSchema::Type::Strict::Hash"]}},
               3=>{:parent=>{:itself=>["Could not coerce '[]' into type: NxtSchema::Type::Strict::Hash"]}},
               4=>{:parent=>{:itself=>["Required key :first_name is missing in {}", "Required key :last_name is missing in {}"]}},
               5=>{:parent=>{:last_name=>{:itself=>["Could not coerce '3000' into type: NxtSchema::Type::Strict::String"]}}},
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
          node.add_schema_error('Can only contain two items')
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
          2=>{:item=>{:itself=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::String"]}},
          3=>{:item=>{:itself=>["Could not coerce '1' into type: NxtSchema::Type::Strict::String"]}},
          4=>{:item=>{:itself=>["Could not coerce '[]' into type: NxtSchema::Type::Strict::String"]}},
          5=>{:item=>{:itself=>["Could not coerce '{}' into type: NxtSchema::Type::Strict::String"]}},
          6=>{:item=>{:itself=>["Could not coerce 'false' into type: NxtSchema::Type::Strict::String"]}},
          7=>{:item=>{:itself=>["Could not coerce 'true' into type: NxtSchema::Type::Strict::String"]}}
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
                                    "furniture.9.table"=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Hash"],
                                    "furniture.9.cupboard"=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Hash"],
                                    "furniture.9.couch"=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Hash"]
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
          "diverse.6.name"=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::String"],
          "diverse.6.age"=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::Integer"],
          "diverse.7.name"=>["Could not coerce 'false' into type: NxtSchema::Type::Strict::String"],
          "diverse.7.age"=>["Could not coerce 'false' into type: NxtSchema::Type::Strict::Integer"],
          "diverse.8.name"=>["Could not coerce '{}' into type: NxtSchema::Type::Strict::String"],
          "diverse.8.age"=>["Could not coerce '{}' into type: NxtSchema::Type::Strict::Integer"],
          "diverse.9.name"=>["Could not coerce '[]' into type: NxtSchema::Type::Strict::String"],
          "diverse.9.age"=>["Could not coerce '[]' into type: NxtSchema::Type::Strict::Integer"]
        )
      end
    end
  end
end