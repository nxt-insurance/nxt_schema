module NxtSchema
  module Types
    include Dry.Types()

    StrippedString = Strict::String.constructor(->(string) { string&.strip })
    LengthyStrippedString = StrippedString.constrained(min_size: 1)
    Enum = -> (*values) { Strict::String.enum(*values) } # Use as NxtSchema::Types::Enum[*ROLES]
    SymbolizedEnum = -> (*values) { Coercible::Symbol.enum(*values) } # Use as NxtSchema::Types::SymboleEnums[*ROLES]
  end
end
