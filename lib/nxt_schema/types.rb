module NxtSchema
  module Types
    include Dry.Types()

    StrippedString = Strict::String.constructor ->(string) { string&.strip }
    StrippedNonBlankString = StrippedString.constrained(min_size: 1)
    Struct = Constructor(::Struct) { |values| ::Struct.new(*values.keys).new(**values) }
  end
end
