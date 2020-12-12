RSpec.describe NxtSchema::Params do
  let(:test_class) do
    Class.new do
      include(NxtSchema::Params)
    end
  end

  context 'register' do
    before do
      test_class.nxt_params.register(
        :create,
        NxtSchema.params do
          required(:first_name, :String)
          required(:last_name, :String)
        end
      )
    end

    describe '#register' do
      it 'registers the schema' do
        expect(test_class.nxt_params.resolve!(:create)).to be_a(NxtSchema::Template::Schema)
        expect(test_class.nxt_params.resolve!(:create).sub_nodes.keys).to match_array([:first_name, :last_name])
      end
    end

    describe '#register!' do
      before do
        test_class.nxt_params.register!(
          :create,
          NxtSchema.params do
            required(:first_name, :String)
          end
        )
      end

      it 'overwrites the previous schema' do
        expect(test_class.nxt_params.resolve!(:create)).to be_a(NxtSchema::Template::Schema)
        expect(test_class.nxt_params.resolve!(:create).sub_nodes.keys).to match_array([:first_name])
      end
    end
  end

  context 'apply' do
    before do
      test_class.nxt_params.register(
        :create,
        NxtSchema.params do
          required(:first_name, :String)
          required(:last_name, :String)
        end
      )
    end

    describe '#apply' do
      it 'registers the schema' do
        expect(test_class.nxt_params.apply(:create, { first_name: 'Andy' })).to be_a(NxtSchema::Node::Schema)

        expect(
          test_class.nxt_params.apply!(
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
          test_class.nxt_params.apply!(
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
      test_class.nxt_params.register(
        :create,
        NxtSchema.params do
          required(:first_name, :String)
          required(:last_name, :String)
        end
      )
    end

    it do
      binding.pry
    end
  end
end
