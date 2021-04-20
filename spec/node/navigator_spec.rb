# frozen_string_literal: true

RSpec.describe NxtSchema::Node::Navigator do

  let(:schema) do
    NxtSchema.schema(:developers) do
      required(:first_name, :String)
      required(:last_name, :String)
      schema(:address) do
        required(:street, :String)
        required(:street_number, :String)
        required(:city, :String)
        required(:zip_code, :String)
        required(:country, :String).validate(:included_in, %w[Germany, France, UK])
      end
    end
  end

  let(:nodes) { schema.apply(input: { first_name: 'Andy' }) }

  let(:node) { nodes[:first_name] }

  subject do
    described_class.new(path, node).call
  end

  context '/' do
    let(:path) { '/' }

    it 'returns the root node' do
      expect(subject).to eq(nodes)
    end
  end

  context './' do
    let(:path) { './' }

    it 'returns the current node' do
      expect(subject).to eq(nodes[:first_name])
    end
  end

  context '/:child_node' do
    let(:path) { '/first_name' }

    it 'returns the child node' do
      expect(subject).to eq(nodes[:first_name])
    end
  end

  context 'nested child node' do
    let(:path) { '/address/zip_code' }

    it 'returns the child node' do
      expect(subject).to eq(nodes[:address][:zip_code])
    end
  end

  context 'parent node' do
    let(:path) { '../' }

    it 'returns the child node' do
      expect(subject).to eq(nodes)
    end
  end
end
