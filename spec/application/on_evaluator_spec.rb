# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input)
  end

  context 'with a method as condition' do
    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        required(:last_name, :String).on(:nil?, 'missing')
      end
    end

    context 'when the method applies' do
      let(:input) { { first_name: 'Andy', last_name: nil } }

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(first_name: 'Andy', last_name: 'missing')
      end
    end

    context 'when the node is missing and thus the method does not apply' do
      let(:input) { { first_name: 'Andy' } }

      it { expect(subject).to_not be_valid }

      it do
        expect(subject.errors).to eq(
          'developers' => ['The following keys are missing: [:last_name]'],
          'developers.last_name' => ["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"]
        )
      end
    end
  end

  context 'with a proc as condition' do
    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        omnipresent(:last_name, :String).on(->(input) { input.is_a?(NxtSchema::MissingInput) }, ->(_input, application) { application.name.to_s } )
      end
    end

    context 'when the method applies' do
      let(:input) { { first_name: 'Andy' } }

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(first_name: 'Andy', last_name: 'last_name')
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

  context 'when passing a block as value' do
    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        required(:last_name, :String).on(true) do |_, application|
          "#{application.name} was not given"
        end
      end
    end

    context 'when the method applies' do
      let(:input) { { first_name: 'Andy', last_name: nil } }

      it { expect(subject).to be_valid }

      it do
        expect(subject.output).to eq(first_name: 'Andy', last_name: 'last_name was not given')
      end
    end
  end
end
