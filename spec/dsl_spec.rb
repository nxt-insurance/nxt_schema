# frozen_string_literal: true

RSpec.describe NxtSchema::Dsl do
  let(:test_class) do
    Class.new do
      extend NxtSchema::Dsl

      module Helpers
        def default_value
          -> (_, node) { "There was no default value for #{node.name} at: #{Time.current}" }
        end
      end

      SCHEMA = schema(:person) do
        extend Helpers

        required(:first_name, :String)
        required(:last_name, :String).default(default_value)
      end

      def call(input)
        SCHEMA.apply(input: input)
      end
    end
  end

  subject { test_class.new.call(first_name: 'Andy', last_name: nil) }

  it 'can access the helper methods' do
    expect(subject.output).to match(
      first_name: "Andy",
      last_name: /There was no default value for last_name at.*/
    )
  end
end
