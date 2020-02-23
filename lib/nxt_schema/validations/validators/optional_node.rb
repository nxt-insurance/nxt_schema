module NxtSchema
  module Validations
    module Validators
      OptionalNode = lambda do |validator|
        lambda do |node, value|
          unless validator.call(*evaluator_args.take(validator.arity))
            true
          else
            node.add_error("Required key missing!")
            false
          end
        end
      end
    end
  end
end