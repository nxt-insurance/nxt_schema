RSpec.describe NxtSchema do
  describe '.root' do
    subject do
      NxtSchema.root do |person|
        person.requires(:first_name, :String)
        person.requires(:last_name, :String)
      end
    end

    context 'when the schema is valid' do
      let(:schema) do
        { first_name: 'Lütfi', last_name: 'Demirci' }
      end

      it do
        subject.apply(schema)
        expect(subject.validation_errors?).to be_falsey
      end
    end

    context 'when the schema is not valid' do
      let(:schema) do
        { first_name: 'Lütfi', last_name: nil }
      end

      it do
        subject.apply(schema)
        expect(subject.validation_errors).to be_truthy
        expect(subject.validation_errors).to eq(:last_name=>{:itself=>["Could not coerce 'nil' into type: NxtSchema::Type::Strict::String"]})
      end
    end
  end

  describe '.roots' do
    subject do
      NxtSchema.roots do |people|
        people.schema(:person) do |person|
          person.requires(:first_name, :String)
          person.requires(:last_name, :String)
        end
      end
    end

    context 'when the schema is valid' do
      let(:schema) do
        [
          { first_name: 'Lütfi', last_name: 'Demirci' },
          { first_name: 'Nils', last_name: 'Sommer' }
        ]
      end

      it do
        subject.apply(schema)
        expect(subject.validation_errors?).to be_falsey
      end
    end

    context 'when the schema is not valid' do
      let(:schema) do
        { first_name: 'Lütfi', last_name: nil }
      end

      it do
        subject.apply(schema)
        expect(subject.validation_errors).to be_truthy
        expect(subject.validation_errors).to eq(
          :itself=>["Could not coerce '{:first_name=>\"Lütfi\", :last_name=>nil}' into type: NxtSchema::Type::Strict::Array"]
        )
      end
    end
  end
end
