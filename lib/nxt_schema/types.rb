module NxtSchema
  module Types
    include Dry.Types()

    StrippedString = Types::Strict::String.constructor ->(string) { string&.strip }
    StrippedNonBlankString = StrippedString.constrained(min_size: 1)
  end
end
