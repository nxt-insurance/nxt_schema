RSpec.describe NxtSchema do
  it "has a version number" do
    expect(NxtSchema::VERSION).not_to be nil
  end

  context 'when the schema is nested' do
    subject do
      NxtSchema.new do |schema|
        schema.node(:company, type: Hash) do |company|
          company.node(:name, type: String)
          company.node(:industry, type: String)

          company.node(:products, type: Hash, optional: true, default: {}, allow: :empty?) do |product|
            product.node(:price, type: Integer)
            product.node(:category, type: String)
          end

          company.node(:employee_names, type: Array) do |node|
            node.type = String
          end
        end
      end
    end

    it do
      schema = subject
      binding.pry
    end
  end
end
