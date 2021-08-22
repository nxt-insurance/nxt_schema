# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input: input)
  end

  let(:schema) do
    NxtSchema.any_of(:possible_combinations) do
      collection(:good_combinations) do
        validate(:attribute, :size, ->(s) { s > 5 })

        any_of(:allowed_good_combinations) do
          schema(:good_combo) do
            required(:color).typed(:String)
            required(:code).typed(:Integer)
          end

          schema(:other_good_combo) do
            required(:length).typed(:Decimal)
          end
        end
      end

      collection(:bad_combinations) do
        any_of(:allowed_bad_combinations) do
          schema(:bad_combo) do
            required(:color).typed(:String)
            required(:code).typed(:Integer)
          end

          schema(:other_bad_combo) do
            required(:height).typed(:Decimal)
          end
        end
      end
    end
  end

  context 'when the input is not valid' do
    let(:input) do
      [
        { color: 'blue', code: 1 },
        { color: 'black', code: 2 },
        { length: 12.to_d }
      ]
    end

    it { expect(subject).to_not be_valid }

    it 'returns the correct errors' do
      expect(subject.errors).to eq(
        "possible_combinations.good_combinations"=>["[{:color=>\"blue\", :code=>1}, {:color=>\"black\", :code=>2}, {:length=>0.12e2}] has invalid size attribute of 3"],
        "possible_combinations.bad_combinations.allowed_bad_combinations[2].bad_combo"=>["The following keys are missing: [:color, :code]"],
        "possible_combinations.bad_combinations.allowed_bad_combinations[2].bad_combo.color"=>["NxtSchema::Undefined violates constraints (type?(String, NxtSchema::Undefined) failed)"],
        "possible_combinations.bad_combinations.allowed_bad_combinations[2].bad_combo.code"=>["NxtSchema::Undefined violates constraints (type?(Integer, NxtSchema::Undefined) failed)"],
        "possible_combinations.bad_combinations.allowed_bad_combinations[2].other_bad_combo"=>["The following keys are missing: [:height]"],
        "possible_combinations.bad_combinations.allowed_bad_combinations[2].other_bad_combo.height"=>["NxtSchema::Undefined violates constraints (type?(BigDecimal, NxtSchema::Undefined) failed)"]
      )
    end
  end
end
