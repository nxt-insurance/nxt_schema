module NxtSchema
  module Node
    class Leaf < Node::Base
      def initialize(name, type, parent_node, **options, &block)
        super
        @type = Types::Registry.fetch(type)
      end

      def validate(target)
        type.coerce(target)

        validations.each do |validation|
          validation_args = [target, self]
          validation.call(*validation_args.take(validation.arity))
        end

        self
      rescue ArgumentError
        add_error(target, "Does not match type: #{type}")
      end
    end
  end
end
