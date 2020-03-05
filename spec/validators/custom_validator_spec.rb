RSpec.describe NxtSchema do
  describe '.register_validator' do
    let(:validator) do
      Class.new(NxtSchema::Validators::Equality)
    end

    before do
      described_class.register_validator(validator, :this_tests_equality)
    end

    let(:schema) do
      NxtSchema.root(:company) do
        requires(:name, :String).validate(:equality, 'getsafe')
      end
    end

    it do
      expect(schema.apply(name: 'getsafe')).to be_valid
      expect(schema.apply(name: 'not getsafe')).to_not be_valid
      expect(schema.errors).to eq("company.name"=>["not getsafe does not equal getsafe"])
    end
  end
end
