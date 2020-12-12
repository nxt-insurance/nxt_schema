# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  context 'with a method' do
    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        required(:last_name, :String).maybe(:blank?)
      end
    end

    context 'when the method applies' do
      let(:input) { { first_name: 'Andy', last_name: '' } }

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(first_name: 'Andy', last_name: '')
      end
    end

    context 'when the method does not apply' do
      let(:input) { { first_name: 'Andy' } }

      it { expect(subject).to_not be_valid }

      it do
        expect(subject.errors).to eq(
          'developers' => ['The following keys are missing: [:last_name]'],
          'developers.last_name' => ['NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)']
        )
      end
    end
  end

  context 'with a proc' do
    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        omnipresent(:last_name, :String).maybe do |input|
          input.is_a?(NxtSchema::Undefined)
        end
      end
    end

    context 'when the method applies' do
      let(:input) { { first_name: 'Andy' } }

      it { expect(subject).to be_valid }

      it do
        expect(
          subject.output
        ).to match(
          first_name: 'Andy',
          last_name: instance_of(NxtSchema::Undefined)
        )
      end
    end

    context 'when the method does not apply' do
      let(:input) { { first_name: 'Andy', last_name: nil } }

      it { expect(subject).to_not be_valid }

      it do
        expect(subject.errors).to eq(
          'developers.last_name' => ['nil violates constraints (type?(String, nil) failed)']
        )
      end
    end
  end

  context 'when passing a simple value' do
    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        required(:last_name, :String).maybe(1)
      end
    end

    context 'when the method applies' do
      let(:input) { { first_name: 'Andy', last_name: 1 } }

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(first_name: 'Andy', last_name: 1)
      end
    end
  end
end
