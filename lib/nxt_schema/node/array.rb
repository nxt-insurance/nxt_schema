module NxtSchema
  module Node
    class Array < Node::Base
      include NxtSchema::Node::Collection

      def initialize(name:, parent_node:, **options, &block)
        @store = []

        super(name: name, type: NxtSchema::Type::Strict::Array, parent_node: parent_node, **options, &block)
      end

      delegate_missing_to :value_store

      def apply(value, parent_schema_errors: {}, parent_value_store: {}, index_or_name: name)
        self.schema_errors = parent_schema_errors[name] ||= { schema_errors_key => [] }
        self.value_store = parent_value_store[index_or_name] ||= []

        if maybe_criteria_applies?(value)
          self.value_store = parent_value_store[index_or_name] = value
        else
          array = type[value]

          if value_violates_emptiness?(array)
            add_error("Array is not allowed to be empty")
          else
            array.each_with_index do |item, index|
              item_errors = schema_errors[index] ||= { schema_errors_key => [] }

              # When an array provides multiple schemas, and none is valid we only return the errors for
              # a single schema => Would probably be better to merge them somehow!!!
              # Might make sense to not allow the same names for multiple schemas in an array
              store.each do |node|
                node.apply(item, parent_schema_errors: { schema_errors_key => [] }, parent_value_store: value_store, index_or_name: index)
                unless node.schema_errors?
                  schema_errors[index][node.name] = node.schema_errors
                  break
                else
                  # TODO: merge errors here instead of assigning
                  schema_errors[index][node.name] = node.schema_errors
                end
              end

              item_errors.reject! { |_, v| v.empty? }
            end

            validations.each do |validation|
              validation_args = [self, array]
              validation.call(*validation_args.take(validation.arity))
            end
          end
        end

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
        self_without_empty_schema_errors
      end

      private

      def merge_errors(first, second)

      end
    end
  end
end
