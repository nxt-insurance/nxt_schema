require_relative 'schema'
require_relative 'collection'
require_relative 'open_struct'
require_relative 'leaf'

module NxtSchema
  module Node
    module HasSubNodes
      attr_accessor :template_store, :value_store

      def node(name, type_or_node, **options, &block)
        child_node = case type_or_node.to_s.to_sym
        when :Hash
          NxtSchema::Node::Schema.new(name: name, type: NxtSchema::Type::Strict::Hash, parent_node: self, **options, &block)
        when :struct
          NxtSchema::Node::OpenStruct.new(name: name, type: NxtSchema::Type::Strict::OpenStruct, parent_node: self, **options, &block)
        when :Array
          NxtSchema::Node::Collection.new(name: name, type: NxtSchema::Type::Strict::Array, parent_node: self, **options, &block)
        else
          if type_or_node.is_a?(NxtSchema::Node::Base)
            node = type_or_node.clone
            node.options.merge!(options)
            node.name = name
            node.parent_node = self
            node
          else
            NxtSchema::Node::Leaf.new(name: name, type: type_or_node, parent_node: self, **options)
          end
        end

        # TODO: Should we check if there is a
        raise KeyError, "Duplicate registration for key: #{name}" if template_store.key?(name)
        template_store.push(child_node)

        child_node
      end

      def required(name, type, **options, &block)
        node(name, type, options.merge(optional: false), &block)
      end

      alias_method :requires, :required

      def optional(name, type, **options, &block)
        node(name, type, options.merge(optional: true), &block)
      end

      def nodes(name, **options, &block)
        node(name, :Array, options, &block)
      end

      alias_method :array, :nodes

      def schema(name, **options, &block)
        node(name, :Hash, options, &block)
      end

      alias_method :hash, :schema

      def dup
        result = super
        result.template_store = template_store.deep_dup
        result.options = options.deep_dup
        result
      end

      delegate_missing_to :value_store

      private

      def value_violates_emptiness?(value)
        value.empty?
      end
    end
  end
end

NxtSchema::Node::Schema.include(::NxtSchema::Node::HasSubNodes)
NxtSchema::Node::Collection.include(::NxtSchema::Node::HasSubNodes)
NxtSchema::Node::OpenStruct.include(::NxtSchema::Node::HasSubNodes)
