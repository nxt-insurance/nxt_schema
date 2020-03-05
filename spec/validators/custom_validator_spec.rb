RSpec.describe NxtSchema do
  describe '.register_validator' do
    let(:equality_validator) do
      Class.new(NxtSchema::Validators::Equality)
    end

    let(:attribute_validator) do
      Class.new(NxtSchema::Validators::Attribute)
    end

    before do
      described_class.register_validator(equality_validator, :this_tests_equality)
      described_class.register_validator(attribute_validator, :attribute_validator)
    end

    let(:schema) do
      NxtSchema.root(:company) do
        requires(:name, :String).validate(:this_tests_equality, 'getsafe')
        requires(:stocks, :Integer).validate(:attribute_validator, :zero?, ->(value) { value })
      end
    end

    it do
      expect(schema.apply(name: 'getsafe', stocks: 0)).to be_valid
      expect(schema.apply(name: 'not getsafe', stocks: 1984)).to_not be_valid
      expect(schema.errors).to eq(
        "company.name"=>["not getsafe does not equal getsafe"],
        "company.stocks" => ["1984 has invalid zero? attribute of false"]
      )
    end
  end
end
