require_relative 'hash'
require_relative 'array'
require_relative 'leaf'

module NxtSchema
  module Node
    module HasSubNodes
      attr_accessor :store, :value_store

      def node(name, type, **options, &block)
        child_node = case type.to_s.to_sym
        when :Hash
          NxtSchema::Node::Hash.new(name: name, parent_node: self, **options, &block)
        when :Array
          NxtSchema::Node::Array.new(name: name, parent_node: self, **options, &block)
        else
          NxtSchema::Node::Leaf.new(name: name, type: type, parent_node: self, **options)
        end

        store.push(child_node)

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

      def schema(name, **options, &block)
        node(name, :Hash, options, &block)
      end
    end
  end
end

NxtSchema::Node::Hash.include(::NxtSchema::Node::HasSubNodes)
NxtSchema::Node::Array.include(::NxtSchema::Node::HasSubNodes)
