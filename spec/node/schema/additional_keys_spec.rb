RSpec.describe NxtSchema::Node::Schema do
  describe '#apply' do
    subject do
      NxtSchema.roots(additional_keys: additional_keys_strategy) do
        schema(:person) do
          requires(:first_name, :String)
          requires(:last_name, :String)
          schema(:skills) do
            required(:run, :Bool)
            required(:jump, :Bool)
            present(:swim, :Bool).default(false)
            optional(:fly, :Bool).default(false)
          end
        end
      end
    end

    let(:values) do
      [
        {
          first_name: 'Raphael',
          last_name: 'Kallensee',
          email: 'rapha@bigdog.de',
          skills: {
            run: true,
            jump: true,
            swim: true,
            fly: true,
            crawl: true,
            fight: false
          }
        },
        {
          first_name: 'Nils',
          last_name: 'Herbst',
          email: 'nils@seasons.de',
          skills: {
            run: true,
            jump: true,
            swim: true,
            fly: true,
            shoot: true
          }
        }
      ]
    end

    context 'when additional keys are allowed' do
      let(:additional_keys_strategy) { :allow }

      it 'adds the additional keys to the result' do
        subject.apply(values)
        expect(subject).to be_valid
        expect(subject.value).to eq(values)
      end
    end

    context 'when additional keys are ignored' do
      let(:additional_keys_strategy) { :ignore }

      it 'ignores additional keys' do
        subject.apply(values)
        expect(subject).to be_valid

        expect(subject.value).to eq(
          [
            {
              :first_name => "Raphael",
              :last_name => "Kallensee",
              :skills => {
                :run => true,
                :jump => true,
                :swim => true,
                :fly => true }
            },
            {
              :first_name => "Nils",
              :last_name => "Herbst",
              :skills => {
                :run => true,
                :jump => true,
                :swim => true,
                :fly => true
              }
            }
          ]
        )
      end
    end

    context 'when additional keys are forbidden' do
      let(:additional_keys_strategy) { :restrict }

      it 'is not valid' do
        subject.apply(values)
        expect(subject).to_not be_valid
        expect(subject.errors).to eq(
          "roots.0.person" => ["Additional keys: [:email] not allowed!"],
          "roots.0.person.skills" => ["Additional keys: [:crawl, :fight] not allowed!"],
          "roots.1.person" => ["Additional keys: [:email] not allowed!"],
          "roots.1.person.skills" => ["Additional keys: [:shoot] not allowed!"]
        )
        expect(subject.value).to eq(
          [
            {
              :first_name => "Raphael",
              :last_name => "Kallensee",
              :skills => {
                :run => true,
                :jump => true,
                :swim => true,
                :fly => true }
            },
            {
              :first_name => "Nils",
              :last_name => "Herbst",
              :skills => {
                :run => true,
                :jump => true,
                :swim => true,
                :fly => true
              }
            }
          ]
        )
      end
    end
  end
end