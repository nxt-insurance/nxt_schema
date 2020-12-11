module NxtSchema
  module Types
    include Dry.Types()
    extend NxtRegistry

    registry(:types, call: false) do
      register(:StrippedString, Strict::String.constructor(->(string) { string&.strip }))
      register(:LengthyStrippedString, resolve!(:StrippedString).constrained(min_size: 1))
      register(:Enum, -> (*values) { Strict::String.enum(*values) })
      register(:SymbolizedEnum, -> (*values) { Coercible::Symbol.enum(*values) })
    end
  end
end
