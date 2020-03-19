RSpec.describe NxtSchema do
  describe 'error messages' do
    context 'with default error messages' do
      let(:schema) do
        NxtSchema.root(:validators) do
          required(:attribute, :String).validate(:attribute, :size, ->(s) { s > 7 })
          required(:equality, :String).validate(:equality, 'getsafe')
          required(:excludes, :Array).validate(:excludes, 'andy')
          required(:includes, :Array).validate(:includes, 'andy')
          nodes(:team).validate(:includes, 'andy') do
            required(:item, :String)
          end
          required(:excluded, :Integer).validate(:excluded, (0..10))
          required(:included, :Integer).validate(:included, (0..10))
          required(:greater_than, :Decimal).validate(:greater_than, '12.34'.to_d)
          required(:greater_than_or_equal, :Decimal).validate(:greater_than_or_equal, '12.34'.to_d)
          required(:less_than, :Decimal).validate(:less_than, '12.34'.to_d)
          required(:less_than_or_equal, :Decimal).validate(:less_than_or_equal, '12.34'.to_d)
          required(:pattern, :String).validate(:pattern, /\d{4}/)
          required(:query, :Integer).validate(:query, :zero?)
        end
      end

      let(:values) do
        {
          attribute: 'small',
          equality: 'lemonade',
          excludes: %w[andy lütfi nils rapha],
          includes: %w[lütfi nils rapha],
          team: %w[lütfi nils rapha],
          excluded: 5,
          included: 15,
          greater_than: '1.234'.to_d,
          greater_than_or_equal: '1.234'.to_d,
          less_than: '123.4'.to_d,
          less_than_or_equal: '123.4'.to_d,
          pattern: '123d',
          query: 1
        }
      end

      subject do
        schema.apply(values)
        schema.errors
      end

      it 'translates the error messages' do
        expect(subject).to eq(
          "validators.attribute"=>["'small' has invalid size of 5"],
          "validators.equality" => ["lemonade does not equal getsafe"],
          "validators.excludes" => ["[\"andy\", \"lütfi\", \"nils\", \"rapha\"] cannot contain andy"],
          "validators.includes" => ["[\"lütfi\", \"nils\", \"rapha\"] must include andy"],
          "validators.greater_than" => ["1.234 must be greater than 12.34"],
          "validators.greater_than_or_equal" => ["1.234 must be greater than or equal to 12.34"],
          "validators.less_than" => ["123.4 must be less than 12.34"],
          "validators.less_than_or_equal" => ["123.4 must be less than or equal to 12.34"],
          "validators.excluded" => ["5 must be excluded in 0..10"],
          "validators.included" => ["15 must be included in 0..10"],
          "validators.pattern" => ["123d must match pattern (?-mix:\\d{4})"],
          "validators.query" => ["1.zero? was false and must be true"],
          "validators.team" => ["[\"lütfi\", \"nils\", \"rapha\"] must include andy"],
        )
      end
    end

    context 'when custom error messages are loaded' do

    end
  end
end
