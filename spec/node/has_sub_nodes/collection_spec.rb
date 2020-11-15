# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input)
  end

  context 'array of leaf nodes' do
    let(:schema) do
      NxtSchema.collection(:developers) do |devs|
        devs.node(:dev, NxtSchema::Types::Strict::String | NxtSchema::Types::Coercible::Float)
      end
    end

    context 'when the input is valid' do
      let(:input) do
        ['Aki', 1, 2, 'Ito', '4.0', 12.to_d]
      end

      it 'returns the correct output' do
        expect(subject.output).to eq(['Aki', 1.0, 2.0, 'Ito', '4.0', 12.0])
      end

      it { expect(subject).to be_valid }
    end

    context 'when the input violates the schema' do
      let(:input) do
        ['Andy', 1, 2, 3.0, BigDecimal(4), [1, 2], {}]
      end

      it 'returns the correct errors' do
        expect(subject).to_not be_valid

        expect(subject.errors).to eq(
          "developers.dev[5]"=>["can't convert Array into Float"],
          "developers.dev[6]"=>["can't convert Hash into Float"]
        )
      end
    end
  end

  context 'array of arrays of nodes' do
    let(:schema) do
      NxtSchema.collection(:developers) do |developers|
        developers.nodes(:frontend_devs) do |frontend_devs|
          frontend_devs.schema(:frontend_dev) do |frontend_dev|
            frontend_dev.node(:name, :String)
            frontend_dev.node(:age, :Integer)
          end
        end
      end
    end

    context 'when the input is valid' do
      let(:input) do
        [
          [{ name: 'Ben', age: 12 }, { name: 'Igor', age: 11 }],
          [{ name: 'Nils', age: 10 }, { name: 'Nico', age: 9 }]
        ]
      end

      it { expect(subject).to be_valid }

      it 'returns the correct output' do
        expect(subject.output).to eq(input)
      end
    end

    context 'when the input violates the schema' do
      let(:input) do
        [
          [{ first_name: 'Ben', age: 12 }, { name: 'Igor', age: 11 }],
          [{ name: 'Nils', age: 10 }, { name: 'Nico', age: 9 }],
          [{ first_name: 'Andy' }, 'invalid', 1, 2],
          []
        ]
      end

      it { expect(subject).to_not be_valid }

      it 'returns the correct errors' do
        expect(subject.errors).to eq(
          "developers.frontend_devs[0].frontend_dev[0]"=>["The following keys are missing: [:name]"],
          "developers.frontend_devs[0].frontend_dev[0].name"=>["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
          "developers.frontend_devs[2].frontend_dev[0]"=>["The following keys are missing: [:name, :age]"],
          "developers.frontend_devs[2].frontend_dev[0].name"=>["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
          "developers.frontend_devs[2].frontend_dev[0].age"=>["NxtSchema::MissingInput violates constraints (type?(Integer, NxtSchema::MissingInput) failed)"],
          "developers.frontend_devs[2].frontend_dev[1]"=>["\"invalid\" violates constraints (type?(Hash, \"invalid\") failed)"],
          "developers.frontend_devs[2].frontend_dev[2]"=>["1 violates constraints (type?(Hash, 1) failed)"],
          "developers.frontend_devs[2].frontend_dev[3]"=>["2 violates constraints (type?(Hash, 2) failed)"],
          "developers.frontend_devs[3]"=>["is not allowed to be empty"]
        )
      end
    end
  end
end
