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
        expect(subject.validation_errors).to eq(:last_name=>{:itself=>["nil violates constraints (type?(String, nil) failed)"]})
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
          :itself=>["{:first_name=>\"Lütfi\", :last_name=>nil} violates constraints (type?(Array, {:first_name=>\"Lütfi\", :last_name=>nil}) failed)"]
        )
      end
    end
  end

  context 'anonymous nodes' do
    subject do
      NxtSchema.roots(transform_keys: :to_sym) do
        ROLES = %i[senior junior intern]

        required(:person, NxtSchema::Types::Struct) do
          requires(:first_name, :String)
          requires(:last_name, NxtSchema::Types::StrippedNonBlankString)
          requires(:role, NxtSchema::Types::SymbolizedEnums[*ROLES])
        end
      end
    end

    let(:schema) do
      [
        { first_name: 'Lütfi', last_name: nil, role: :senior },
        { first_name: ['Nils'], last_name: 'Sommer', role: :senior },
        { 'first_name' => 'Andreas', 'last_name' => 'Kallensee', 'role' => 'too old' }
      ]
    end

    it 'names the nodes based on their index' do
      subject.apply(schema)

      expect(subject.errors).to eq(
        "roots.0.person.last_name"=>["nil violates constraints (type?(String, nil) failed)"],
        "roots.1.person.first_name"=>["[\"Nils\"] violates constraints (type?(String, [\"Nils\"]) failed)"],
        "roots.2.person.role" => ["\"too old\" violates constraints (included_in?([:senior, :junior, :intern], :\"too old\") failed)"]
      )
    end
  end
end
