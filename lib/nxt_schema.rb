require "nxt_schema/version"
require "pry"
require "active_support/all"

require "nxt_schema/registry"

require "nxt_schema/errors"
require "nxt_schema/errors/error"
require "nxt_schema/errors/required_key_missing_error"
require "nxt_schema/errors/coercion_error"

require "nxt_schema/type"
require "nxt_schema/type/strict"
require "nxt_schema/type/strict/base"
require "nxt_schema/type/strict/array"
require "nxt_schema/type/strict/open_struct"
require "nxt_schema/type/strict/hash"
require "nxt_schema/type/strict/string"
require "nxt_schema/type/strict/integer"
require "nxt_schema/type/strict/float"
require "nxt_schema/type/strict/big_decimal"
require "nxt_schema/type/strict/boolean"

require "nxt_schema/node"
require "nxt_schema/node/maybe_evaluator"
require "nxt_schema/node/optional_node_validator"
require "nxt_schema/node/base"
require "nxt_schema/node/error"
require "nxt_schema/node/has_subnodes"
require "nxt_schema/node/template_store"
require "nxt_schema/node/hash"
require "nxt_schema/node/open_struct"
require "nxt_schema/node/array"
require "nxt_schema/node/leaf"
require "nxt_schema/dsl"

module NxtSchema

end
