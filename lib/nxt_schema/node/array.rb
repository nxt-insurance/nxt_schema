module NxtSchema
  module Node
    class Array < Node::Base
      include NxtSchema::Node::Collection

      def initialize(name:, parent_node:, **options, &block)
        @store = []

        super(name: name, type: NxtSchema::Type::Strict::Array, parent_node: parent_node, **options, &block)
      end

      delegate_missing_to :value_store

      def apply(value, parent_schema_errors: {}, parent_value_store: {}, parent_validation_errors: {}, index_or_name: name)
        self.schema_errors = parent_schema_errors[name] ||= { schema_errors_key => [] }
        self.validation_errors = parent_validation_errors[name] ||= { schema_errors_key => [] }
        self.value_store = parent_value_store[index_or_name] ||= []
        all_nodes << self

        if maybe_criteria_applies?(value)
          self.value_store = parent_value_store[index_or_name] = value
          self.value = array
        else
          array = type[value]
          self.value = array

          if value_violates_emptiness?(array)
            add_schema_error("Array is not allowed to be empty")
          else
            array.each_with_index do |item, index|
              item_schema_errors = schema_errors[index] ||= { schema_errors_key => [] }
              validation_errors[index] ||= { schema_errors_key => [] }
              # When an array provides multiple schemas, and none is valid we only return the errors for
              # a single schema => Would probably be better to merge them somehow!!!
              # Might make sense to not allow the same names for multiple schemas in an array
              store.each do |node|
                current_node = node.dup

                current_node.apply(
                  item,
                  parent_schema_errors: { schema_errors_key => [] },
                  parent_validation_errors: { schema_errors_key => [] },
                  parent_value_store: value_store,
                  index_or_name: index
                )

                unless current_node.schema_errors?
                  schema_errors[index][current_node.name] = current_node.schema_errors
                  validation_errors[index][current_node.name] = current_node.validation_errors
                  break
                else
                  # TODO: merge errors here instead of assigning
                  schema_errors[index][current_node.name] = current_node.schema_errors
                  validation_errors[index][current_node.name] = current_node.validation_errors
                end
              end

              # item_validation_errors.reject! { |_, v| v.empty? }
              item_schema_errors.reject! { |_, v| v.empty? }
            end

            # # TODO: Setup validations here
            # Array(options.fetch(:validate, [])).each do |validation|
            #   validation_args = [self, array]
            #   validation.call(*validation_args.take(validation.arity))
            # end
          end
        end

        self_without_empty_schema_errors
      rescue NxtSchema::Errors::CoercionError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end

      private

      def merge_errors(first, second)

      end
    end
  end
end
