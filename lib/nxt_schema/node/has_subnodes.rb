require_relative 'schema'
require_relative 'collection'
require_relative 'struct'
require_relative 'leaf'

module NxtSchema
  module Node
    module HasSubNodes
      attr_accessor :template_store, :value_store

      def node(name, type_or_node, **options, &block)
        child_node = case type_or_node.to_s.to_sym
        when :Hash
          NxtSchema::Node::Schema.new(name: name, type: NxtSchema::Types::Strict::Hash, parent_node: self, **options, &block)
        when :Struct
          # TODO: This should not be limited to OpenStruct
          NxtSchema::Node::Struct.new(name: name, type: NxtSchema::Types::Constructor(::OpenStruct), parent_node: self, **options, &block)
        when :Array
          NxtSchema::Node::Collection.new(name: name, type: NxtSchema::Types::Strict::Array, parent_node: self, **options, &block)
        else
          # TODO: Probably not possible since we cast to string above?
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

      # TODO: This does only belong in schema nodes (maybe there should be a module for that)
      def optional(name, type, **options, &block)
        raise ArgumentError, "Options ubiquitous <=> optional exclude each other!" if options[:ubiquitous]

        node(name, type, options.merge(optional: true), &block)
      end

      # TODO: This does only belong in schema nodes (maybe there should be a module for that)
      def ubiquitous(name, type, **options, &block)
        raise ArgumentError, "Options ubiquitous <=> optional exclude each other!" if options[:optional]

        node(name, type, options.merge(ubiquitous: true), &block)
      end

      def nodes(name, **options, &block)
        node(name, :Array, options, &block)
      end

      alias_method :array, :nodes

      def schema(name, **options, &block)
        node(name, :Hash, options, &block)
      end

      alias_method :hash, :schema

      def struct(name, **options, &block)
        node(name, :Struct, options, &block)
      end

      def dup
        result = super
        result.template_store = template_store.deep_dup
        result.options = options.deep_dup
        result
      end

      delegate_missing_to :value_store

      private

      def value_violates_emptiness?(value)
        return true unless value.respond_to?(:empty?)

        value.empty?
      end
    end
  end
end

NxtSchema::Node::Schema.include(::NxtSchema::Node::HasSubNodes)
NxtSchema::Node::Collection.include(::NxtSchema::Node::HasSubNodes)
NxtSchema::Node::Struct.include(::NxtSchema::Node::HasSubNodes)
