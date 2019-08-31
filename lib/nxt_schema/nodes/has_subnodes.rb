require_relative 'hash_node'
require_relative 'array_node'
require_relative 'simple_node'

module NxtSchema
  module Nodes
    module HasSubNodes
      attr_accessor :store, :value_store

      def node(name, type, **options, &block)
        child_node = case type.to_s
        when 'Hash'
          NxtSchema::Nodes::HashNode.new(name, self, **options, &block)
        when 'Array'
          NxtSchema::Nodes::ArrayNode.new(name, self, **options, &block)
        else
          NxtSchema::Nodes::SimpleNode.new(name, type,self, **options)
        end

        store.push(child_node)
      end

      def required(name, type, **options, &block)
        node(name, type, options.merge(optional: false), &block)
      end

      alias_method :requires, :required

      def optional(name, type, **options, &block)
        node(name, type, options.merge(optional: true), &block)
      end

      def nodes(name, **options, &block)
        node(name, Array, options, &block)
      end
    end
  end
end

NxtSchema::Nodes::HashNode.include(::NxtSchema::Nodes::HasSubNodes)
NxtSchema::Nodes::ArrayNode.include(::NxtSchema::Nodes::HasSubNodes)
