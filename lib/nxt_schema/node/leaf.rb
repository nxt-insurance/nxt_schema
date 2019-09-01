module NxtSchema
  module Node
    class Leaf < Node::Base
      def initialize(name, type, parent_node, **options, &block)
        super
        @type = resolve_type(type)
      end

      def validate(value)
        value = type[value]

        validations.each do |validation|
          validation_args = [value, self]
          validation.call(*validation_args.take(validation.arity))
        end

        self
      rescue ArgumentError
        add_error(value, "Does not match type: #{type}")
      end
    end
  end
end
