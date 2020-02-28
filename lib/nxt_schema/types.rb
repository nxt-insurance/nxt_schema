module NxtSchema
  module Types
    include Dry.Types()

    StrippedString = Strict::String.constructor ->(string) { string&.strip }
    StrippedNonBlankString = StrippedString.constrained(min_size: 1)
    Struct = Constructor(::Struct) { |hash| ::Struct.new(*hash.keys).new(*hash.values) }
    Enums = -> (*values) { Strict::String.enum(*values) } # Use as NxtSchema::Types::Enums[*ROLES]
    SymbolizedEnums = -> (*values) { Coercible::Symbol.enum(*values) } # Use as NxtSchema::Types::SymboleEnums[*ROLES]
  end
end
