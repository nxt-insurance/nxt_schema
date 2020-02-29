require "nxt_schema/version"
require "pry"
require "active_support/all"
require 'dry-types'
require 'nxt_registry'

require "nxt_schema/types"
require "nxt_schema/undefined"
require "nxt_schema/registry"
require "nxt_schema/callable"
require "nxt_schema/callable_or_value"
require "nxt_schema/validations/registry"
require "nxt_schema/validations/validate_with_proxy"

require "nxt_schema/validations/validators/validator"
require "nxt_schema/validations/validators/attribute"
require "nxt_schema/validations/validators/equality"
require "nxt_schema/validations/validators/optional_node"
require "nxt_schema/validations/validators/greater_than"
require "nxt_schema/validations/validators/greater_than_or_equal"
require "nxt_schema/validations/validators/less_than"
require "nxt_schema/validations/validators/less_than_or_equal"
require "nxt_schema/validations/validators/pattern"
require "nxt_schema/validations/validators/inclusion"
require "nxt_schema/validations/validators/exclusion"
require "nxt_schema/validations/validators/query"

require "nxt_schema/errors"
require "nxt_schema/errors/error"
require "nxt_schema/errors/schema_not_applied_error"

require "nxt_schema/node"
require "nxt_schema/node/maybe_evaluator"
require "nxt_schema/node/default_value_evaluator"
require "nxt_schema/node/base"
require "nxt_schema/node/error"
require "nxt_schema/node/has_subnodes"
require "nxt_schema/node/template_store"
require "nxt_schema/node/schema"
require "nxt_schema/node/constructor"
require "nxt_schema/node/collection"
require "nxt_schema/node/leaf"
require "nxt_schema/dsl"

module NxtSchema

end
