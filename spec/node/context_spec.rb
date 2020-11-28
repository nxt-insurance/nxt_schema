# frozen_string_literal: true

RSpec.describe NxtSchema do

  let(:last_name) { 'Stoianov' }

  context 'when a context is given at apply time' do
    subject { schema.apply(input: input, context: apply_context) }

    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        required(:last_name, :String).default do |_, node|
          node.context.default_last_name
        end
      end
    end

    let(:apply_context) do
      Module.new do
        def default_last_name
          'Stoianov'
        end

        module_function :default_last_name
      end
    end

    let(:input) { { first_name: 'Nico', last_name: nil } }

    it { expect(subject).to be_valid }

    it { expect(subject.output).to eq(first_name: 'Nico', last_name: 'Stoianov') }
  end

  context 'when a context is given at definition time' do
    subject { schema.apply(input: input) }

    let(:schema) do
      NxtSchema.schema(:developers, context: build_context) do
        required(:first_name, :String)
        required(:last_name, :String).validate(context.validate_last_name)
      end
    end

    let(:build_context) do
      Module.new do
        def validate_last_name
          ->(node) { node.add_error('Invalid last name') unless node.input == 'Stoianov' }
        end

        module_function :validate_last_name
      end
    end

    let(:input) { { first_name: 'Nico', last_name: 'Other' } }

    it { expect(subject).to_not be_valid }

    it { expect(subject.errors).to eq("developers.last_name" => ["Invalid last name"]) }
  end
end
