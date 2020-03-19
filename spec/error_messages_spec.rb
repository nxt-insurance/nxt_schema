RSpec.describe NxtSchema do
  describe 'error messages' do
    context 'with default error messages' do
      let(:schema) do
        NxtSchema.root(:validators) do
          required(:attribute, :String).validate(:attribute, :size, ->(s) { s > 7 })
        end
      end

      let(:values) do
        { attribute: 'small' }
      end

      subject do
        schema.apply(values)
        schema.errors
      end

      it 'translates the error messages' do
        binding.pry
      end
    end

    context 'when custom error messages are loaded' do

    end
  end
end
