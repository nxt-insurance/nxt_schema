RSpec.describe NxtSchema do
  context 'an array of required primitive types' do
    let(:schema) do
      NxtSchema.roots(:movies) do
        node(:movie, :String)
      end
    end

    subject do
      schema.apply(values)
    end

    context 'when the values are valid' do
      let(:values) do
        %w[Matrix Blow Titanic]
      end

      it do
        expect(subject).to be_valid
      end
    end

    context 'when the values are not valid' do
      let(:values) do
        %w[Matrix Blow Titanic] + [1]
      end

      it do
        expect(subject).to_not be_valid
        expect(subject.errors).to eq("movies.3.movie"=>["1 violates constraints (type?(String, 1) failed)"])
      end
    end
  end

  context 'an array of multiple different types' do
    let(:schema) do
      NxtSchema.roots(:movies) do
        node(:movie, :String)
        schema(:movie_schema) do
          node(:name, :String)
          node(:category, :String)
        end
      end
    end

    subject do
      schema.apply(values)
    end

    context 'when the values are valid' do
      let(:values) do
        %w[Matrix Blow Titanic] + [{ name: 'Bugs Bunny', category: 'Cartoon' }]
      end

      it do
        expect(subject).to be_valid
      end
    end

    context 'when the values are not valid' do
      let(:values) do
        %w[Matrix Blow Titanic] + [1]
      end

      it do
        expect(subject).to_not be_valid
        expect(subject.errors).to eq(
          "movies.3.movie"=>["1 violates constraints (type?(String, 1) failed)"],
          "movies.3.movie_schema"=>["1 violates constraints (type?(Hash, 1) failed)"]
        )
      end
    end
  end
end
