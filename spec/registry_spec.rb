RSpec.describe NxtSchema::Registry do
  let(:test_class) do
    Class.new do
      include(NxtSchema::Registry)
    end
  end

  context 'register' do
    before do
      test_class.schemas.register(
        :create,
        NxtSchema.params do
          required(:first_name, :String)
          required(:last_name, :String)
        end
      )
    end

    describe '#register' do
      it 'registers the schema' do
        expect(test_class.schemas.resolve!(:create)).to be_a(NxtSchema::Template::Schema)
        expect(test_class.schemas.resolve!(:create).sub_nodes.keys).to match_array([:first_name, :last_name])
      end
    end

    describe '#register!' do
      before do
        test_class.schemas.register!(
          :create,
          NxtSchema.params do
            required(:first_name, :String)
          end
        )
      end

      it 'overwrites the previous schema' do
        expect(test_class.schemas.resolve!(:create)).to be_a(NxtSchema::Template::Schema)
        expect(test_class.schemas.resolve!(:create).sub_nodes.keys).to match_array([:first_name])
      end
    end
  end

  context 'apply' do
    before do
      test_class.schemas.register(
        :create,
        NxtSchema.params do
          required(:first_name, :String)
          required(:last_name, :String)
        end
      )
    end

    describe '#apply' do
      it 'registers the schema' do
        expect(test_class.schemas.apply(:create, { first_name: 'Andy' })).to be_a(NxtSchema::Node::Schema)

        expect(
          test_class.schemas.apply!(
            :create,
            { first_name: 'Andy', last_name: 'Robecke' })
        ).to eq(
          first_name: 'Andy',
          last_name: 'Robecke'
        )
      end
    end

    describe '#apply!' do
      it 'applies the input' do
        expect(
          test_class.new.schemas.apply!(
            :create,
            { first_name: 'Andy', last_name: 'Robecke' }
          )
        ).to eq(
          first_name: 'Andy',
          last_name: 'Robecke'
        )
      end
    end
  end

  context 'inheritance' do
    let(:child_class) do
      Class.new(test_class)
    end

    before do
      test_class.schemas.register(
        :create,
        NxtSchema.params do
          required(:first_name, :String)
          required(:last_name, :String)
        end
      )
    end

    it 'inherits the schemas to the subclass' do
      test_class.schemas.each do |key, schema|
        expect(child_class.new.schemas.resolve(key)).to eq(schema)
      end
    end
  end
end
