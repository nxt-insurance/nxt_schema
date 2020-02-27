module NxtSchema
  module Node
    class Collection < Node::Base
      def initialize(name:, type: NxtSchema::Types::Strict::Array, parent_node:, **options, &block)
        @template_store = TemplateStore.new
        super
      end

      def apply(value, parent_node: self.parent_node, context: nil)
        register_node(context)

        self.parent_node = parent_node
        self.schema_errors = { schema_errors_key => [] }
        self.validation_errors = { schema_errors_key => [] }
        self.value_store = []
        self.value = value

        if maybe_criteria_applies?
          self.value_store = value
        else
          self.value = value_or_default_value

          unless maybe_criteria_applies?
            self.value = type[value_or_default_value]

            # TODO: We should probably name differentiate between given value and self.value

            # if value_violates_emptiness?(value)
            #   add_schema_error("Array is not allowed to be empty")
            # else
              current_node_store = {}

            self.value.each_with_index do |item, index|
                item_schema_errors = schema_errors[index] ||= { schema_errors_key => [] }
                validation_errors[index] ||= { schema_errors_key => [] }

                template_store.each do |node_name, node|
                  current_node = node.dup
                  current_node_store[node_name] = current_node

                  current_node.apply(item, parent_node: self, context: context)

                  value_store[index] = current_node.value

                  unless current_node.schema_errors?
                    current_node_store.each do |node_name, node|
                      node.schema_errors = { }
                      node.validation_errors = { }
                      item_schema_errors = schema_errors[index][node_name] = node.schema_errors
                      validation_errors[index][node_name] = node.validation_errors
                    end

                    break
                  else
                    schema_errors[index][node_name] = current_node.schema_errors
                    validation_errors[index][node_name] = current_node.validation_errors
                  end
                end

                item_schema_errors.reject! { |_, v| v.empty? }
              end
            # end

            # TODO: Do we need this?
            self.value_store = type[value_store]
            self.value = value_store
          end
        end

        self_without_empty_schema_errors
      rescue Dry::Types::ConstraintError => error
        add_schema_error(error.message)
        self_without_empty_schema_errors
      end
    end
  end
end
