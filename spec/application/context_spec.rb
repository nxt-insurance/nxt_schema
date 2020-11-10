# frozen_string_literal: true

RSpec.describe NxtSchema do
  subject do
    schema.apply(input, context)
  end

  context 'when a context is given' do
    let(:schema) do
      NxtSchema.schema(:developers) do
        required(:first_name, :String)
        required(:last_name, :String).default do |_, node|
          node.context.default_last_name
        end
      end
    end

    let(:context) do
      Module.new do
        def default_last_name
          'Stoianov'
        end

        module_function :default_last_name
      end
    end

    let(:input) { { first_name: 'Nico', last_name: nil } }

    it { expect(subject).to be_valid }

    it 'has access to the context during application' do
      expect(subject.output).to eq(first_name: 'Nico', last_name: 'Stoianov')
    end
  end
end
