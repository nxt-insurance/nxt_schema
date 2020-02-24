RSpec.describe NxtSchema do
  context 'optional keys' do
    context 'when keys in the schema are optional' do
      let(:email_validator) do
        lambda do |node, value|
          unless value.include?('@')
            node.add_error('Email is not valid')
          end
        end
      end

      subject do
        NxtSchema.root do |person|
          person.requires(:first_name, :String)
          person.optional(:last_name, :String)
          person.optional(:email, :String).validate(email_validator)
        end
      end

      context 'when the optional keys are not given' do
        let(:schema) do
          { first_name: 'Andy' }
        end

        it do
          subject.apply(schema)
          expect(subject.validation_errors?).to be_falsey
          expect(subject.value_store).to eq(schema)
        end
      end

      context 'when the optional keys are given' do
        context 'and validations are valid' do
          let(:schema) do
            { first_name: 'Andy', email: 'andreas@robecke.de' }
          end

          it do
            subject.apply(schema)
            expect(subject.validation_errors?).to be_falsey
            expect(subject.value_store).to eq(schema)
          end
        end

        context 'and validations fail' do
          let(:schema) do
            { first_name: 'Andy', email: 'invalid' }
          end

          it do
            subject.apply(schema)
            expect(subject.validation_errors).to be_truthy
            expect(subject.value_store).to eq(schema)
            expect(subject.validation_errors).to eq(:email=>{:itself=>["Email is not valid"]})
          end
        end
      end
    end

    context 'when keys in the schema are conditionally optional' do
      subject do
        NxtSchema.root do
          nodes(:employees) do
            schema(:employee) do
              node(:name, :String).optional ->(employee) { employee.empty? }
              node(:email, :String).optional ->(employee) { employee.empty? || employee[:name] == 'Andy' }
            end
          end
        end
      end

      context 'when the node is required' do
        let(:schema) do
          {
            headquarter: {
              street: 'Langer Anger'
            },
            employees: [
              { },
              { email: 'andy@awesome.com' },
              { name: 'Andy' },
              { name: 'Nils' },
              { name: 'Raphael', email: 'rapha@kallensee.de' },
              nil,
              'Here'
            ]
          }
        end

        it do
          subject.apply(schema)

          expect(subject.errors).to eq(
            "root.employees.1.employee"=>["Required key :name is missing in {:email=>\"andy@awesome.com\"}"],
            "root.employees.3.employee"=>["Required key :email is missing in {:name=>\"Nils\"}"],
            "root.employees.5.employee"=>["nil violates constraints (type?(Hash, nil) failed)"],
            "root.employees.6.employee"=>["\"Here\" violates constraints (type?(Hash, \"Here\") failed)"]
          )
        end
      end
    end
  end

  context 'complex example' do
    subject do
      NxtSchema.roots(:movies) do
        schema(:movie) do
          requires(:title, :String)
          nodes(:categories) do
            requires(:category, :String)
          end
          nodes(:ratings) do
            schema(:rating) do
              optional(:stars, :Integer).validate -> (node, value) { node.add_error('Max 5 stars!') if value > 5 }
              node(:is_good_rating, :Bool).optional -> (node) { node[:stars] && node[:stars] < 3 }
            end
          end
        end
      end
    end

    let(:schema) do
      [
        {
          title: 'Forest Gump',
          categories: ['Comedy', 'Drama'],
          ratings: [
            { stars: 1 },
            { stars: 4 },
            { stars: 5, is_good_rating: true }
          ]
        },
        {
          title: 'Blow',
          categories: ['Action', 'Drama'],
          ratings: [
            { stars: nil },
            { stars: 4 },
            { stars: 5, is_good_rating: true },
            nil,
            {}
          ]
        }
      ]
    end

    it 'works' do
      subject.apply(schema)

      expect(subject.errors).to eq(
        "movies.0.movie.ratings.1.rating"=>["Required key :is_good_rating is missing in {:stars=>4}"],
        "movies.1.movie.ratings.0.rating"=>["Required key :is_good_rating is missing in {:stars=>nil}"],
        "movies.1.movie.ratings.0.rating.stars"=>["nil violates constraints (type?(Integer, nil) failed)"],
        "movies.1.movie.ratings.1.rating"=>["Required key :is_good_rating is missing in {:stars=>4}"],
        "movies.1.movie.ratings.3.rating"=>["nil violates constraints (type?(Hash, nil) failed)"],
        "movies.1.movie.ratings.4.rating"=>["Required key :is_good_rating is missing in {}"]
      )
      expect(subject.value).to eq(schema)
    end
  end
end
