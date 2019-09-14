module NxtSchema
  module Node
    class Array < Node::Base
      def initialize(name:, parent_node:, **options, &block)
        @template_store = TemplateStore.new

        super(name: name, type: NxtSchema::Type::Strict::Array, parent_node: parent_node, **options, &block)
      end

      def apply(value, parent_node: parent_node, parent_schema_errors: {}, parent_value_store: {}, parent_validation_errors: {}, index_or_name: name)
        self.parent_node = parent_node
        self.schema_errors = parent_schema_errors[index_or_name] ||= { schema_errors_key => [] }
        self.validation_errors = parent_validation_errors[index_or_name] ||= { schema_errors_key => [] }
        self.value_store = parent_value_store[index_or_name] ||= []
        register_node
        self.value = value

        if maybe_criteria_applies?(value)
          self.value_store = parent_value_store[index_or_name] = value
        else
          array = type[value]
          self.value = array

          if value_violates_emptiness?(array)
            add_schema_error("Array is not allowed to be empty")
          else
            current_node_store = {}

            array.each_with_index do |item, index|
              item_schema_errors = schema_errors[index] ||= { schema_errors_key => [] }
              validation_errors[index] ||= { schema_errors_key => [] }
              # When an array provides multiple schemas, and none is valid we only return the errors for
              # a single schema => Would probably be better to merge them somehow!!!
              # Might make sense to not allow the same names for multiple schemas in an array
              template_store.each do |node_name, node|
                current_node = node.dup
                current_node_store[node_name] = node
                # register_node(current_parent_node)
                # current_parent_node.value_store = value_store.deep_dup

                current_node.apply(
                  item,
                  parent_node: self,
                  parent_schema_errors: { schema_errors_key => [] },
                  parent_validation_errors: { schema_errors_key => [] },
                  parent_value_store: value_store,
                  index_or_name: index
                )

                unless current_node.schema_errors?
                  schema_errors[index] = { schema_errors_key => [] }
                  item_schema_errors = schema_errors[index]
                  validation_errors[index] = { schema_errors_key => [] }
                  break
                else
                  schema_errors[index][node_name] = current_node.schema_errors
                  validation_errors[index][node_name] = current_node.validation_errors
                end
              end

              item_schema_errors.reject! { |_, v| v.empty? }
            end
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
