RSpec.describe NxtSchema do
  subject { schema.apply(input) }

  context 'any of collections of any of schemas' do
    let(:schema) do
      NxtSchema.any_of(:possible_combinations) do
        collection(:good_combinations) do
          any_of(:allowed_good_combinations) do
            schema(:good_combo) do
              required(:color, :String)
              required(:code, :Integer)
            end

            schema(:other_good_combo) do
              required(:length, :Decimal)
            end
          end
        end

        collection(:bad_combinations) do
          any_of(:allowed_bad_combinations) do
            schema(:bad_combo) do
              required(:color, :String)
              required(:code, :Integer)
            end

            schema(:other_bad_combo) do
              required(:height, :Decimal)
            end
          end
        end
      end
    end

    context 'when the input is valid' do
      let(:input) do
        [
          { color: 'blue', code: 1 },
          { color: 'black', code: 2 },
          { length: 12.to_d }
        ]
      end

      it { expect(subject).to be_valid }

      it { expect(subject.output).to eq(input) }
    end

    context 'when the input is not valid' do
      let(:input) do
        [
          { color: 'blue', code: 1 },
          { color: 'black', code: 2 },
          { length: 12.to_d },
          { height: 12.to_d }
        ]
      end

      it { expect(subject).to_not be_valid }

      it do
        expect(subject.schema_errors).to eq(
          good_combinations: {
            3 => {
              good_combo: {
                itself: ["The following keys are missing: [:color, :code]"],
                color: ["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
                code: ["NxtSchema::MissingInput violates constraints (type?(Integer, NxtSchema::MissingInput) failed)"]
              },
              other_good_combo: {
                itself: ["The following keys are missing: [:length]"],
                length: ["NxtSchema::MissingInput violates constraints (type?(BigDecimal, NxtSchema::MissingInput) failed)"]
              }
            }
          },
          bad_combinations: {
            2 => {
              bad_combo: {
                itself: ["The following keys are missing: [:color, :code]"],
                color: ["NxtSchema::MissingInput violates constraints (type?(String, NxtSchema::MissingInput) failed)"],
                code: ["NxtSchema::MissingInput violates constraints (type?(Integer, NxtSchema::MissingInput) failed)"]
              },
              other_bad_combo: {
                itself: ["The following keys are missing: [:height]"],
                height: ["NxtSchema::MissingInput violates constraints (type?(BigDecimal, NxtSchema::MissingInput) failed)"]
              }
            }
          }
        )
      end
    end
  end
end
