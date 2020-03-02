RSpec.describe NxtSchema::Node::Schema do
  describe '#apply' do
    subject do
      NxtSchema.root(additional_keys: additional_keys_strategy) do
        required(:first_name, :String)
        required(:last_name, :String)
      end
    end

    let(:values) do
      {
        first_name: 'Raphael',
        last_name: 'Kallensee',
        email: 'rapha@bigdog.de'
      }
    end

    context 'when additional keys are allowed' do
      let(:additional_keys_strategy) { :allow }

      it 'adds the additional keys to the result' do
        subject.apply(values)
        expect(subject).to be_valid
        expect(subject.value).to eq(values)
      end
    end

    context 'when additional keys are ignored' do
      let(:additional_keys_strategy) { :ignore }

      it 'ignores additional keys' do
        subject.apply(values)
        expect(subject).to be_valid
        expect(subject.value).to eq(values.except(:email))
      end
    end

    context 'when additional keys are forbidden' do
      let(:additional_keys_strategy) { :restrict }

      it 'is not valid' do
        subject.apply(values)
        expect(subject).to_not be_valid
        expect(subject.errors).to eq("root"=>["Additional keys: [:email] not allowed!"])
        expect(subject.value).to eq(values.except(:email))
      end
    end
  end
end