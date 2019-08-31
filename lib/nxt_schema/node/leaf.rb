module NxtSchema
  module Node
    class Leaf < Node::Base
      def validate(target)
        if target.is_a?(type)
          validations.each do |validation|
            validation_args = [target, self]
            validation.call(*validation_args.take(validation.arity))
          end
        else
          add_error(target, "Does not match type: #{type}")
        end

        self
      end
    end
  end
end
