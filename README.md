# NxtSchema

## TODO:

- Allow to disable validation when applying 
    --> Are there attributes that should be moved to apply time?
- Should we have a global and a local registry for validators?
    --> Would be cool to register things for the schema only
    --> Would be cool if this was extendable 
- Do we need all off in order to combine multiple schemas? 
- Cloning of nodes would not work without configuration <<- Either makes this mandatory / or clone properly!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nxt_schema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nxt_schema

## What it is for?

NxtSchema is a type casting and validation framework that allows you to validate and type cast arbitrary nested 
structures of data. 

### Usage

```ruby
PERSON = NxtSchema.schema(:person) do
  node(:first_name, :String)
  node(:last_name, :String)
  node(:email, :String, optional: true).validate(:includes, '@')
end

input = {
  first_name: 'Andy',
  last_name: 'Robecke',
  email: 'andreas@robecke.de'
}

result = PERSON.apply(input: input)

result.valid? # => true
result.output # => input
```  

### Nodes

A schema consists of a number of nodes. Every node has a name and an associated type for casting it's input when the 
schema is applied. Schemas can consist of 4 different kinds of nodes: 

```ruby
NxtSchema::Node::Schema # => Hash of values 
NxtSchema::Node::Collection # => Array of values
NxtSchema::Node::AnyOf # => Any of the defined schemas
NxtSchema::Node::Leaf # => Node without sub nodes
```

The kind of node dictates how the schema is applied to the input. On the root level the following methods are available
to create schemas:

```ruby
  NxtSchema.schema { ... } # => Create a schema node 
  NxtSchema.collection { ... } # => Create an array of nodes
  NxtSchema.any_of { ... } # => Create a collection of allowed schemas
```

#### Node predicate aliases

Of course these nodes can be combined and nested in arbitrary manner. When defining nodes within a schema, nodes are 
always required per default. You can create nodes with the node method or several useful helper methods. 

```ruby
NxtSchema.schema(:person) do
  required(:first_name, :String) # => same as node(:first_name, :String)
  optional(:last_name, :String) # => same as node(:first_name, :String, optional: true)
  omnipresent(:email, :String) # => same as node(:first_name, :String, omnipresent: true)
end
```

**NOTE: The methods above only apply to the keys of your schema and do not make any assumptions about values!**

In other word this means that making a node optional only makes your node optional. When your input contains the key but
the value is nil, you will still get an error in case there is no default or maybe expression that applies. Omnipresent
node also only inject the node into the schema but do not inject a default value. In order to inject a key with value 
into a schema you also have to combine the node predicates with default value method described below. For clarification
check out the examples below:

```ruby
schema = NxtSchema.schema(:person) do
  optional(:email, :String)
end

result = schema.apply(input: { email: nil })
result.errors # => {"person.email"=>["nil violates constraints (type?(String, nil) failed)"]}
result.output # => {:email=>nil}

result = schema.apply(input: {})
result.errors # => {}
result.output # => {}
```

```ruby
schema = NxtSchema.schema(:person) do
  optional(:email, :String).default('andreas@robecke.de')
end

result = schema.apply(input: { email: nil })
result.errors # => {}

result = schema.apply(input: {})
result.errors # => {}
result.output # => {:email=>"andreas@robecke.de"}
```

```ruby
schema = NxtSchema.schema(:person) do
  omnipresent(:email, :String)
end

result = schema.apply(input: {})
result.errors # => {}
result.output # => {:email=>NxtSchema::MissingInput}
```

```ruby
schema = NxtSchema.schema(:person) do
  # make sure a node is always present and at least nil even though the type is String
  omnipresent(:email, :String).default(nil).maybe(:nil?)
end

result = schema.apply(input: {})
result.errors # => {}
result.output # => {:email=>nil}

result = schema.apply(input:  { email: 'andreas@robecke.de' })
result.errors # => {}
result.output # => {:email=>"andreas@robecke.de"}
```

##### Conditionally optional nodes

You can also pass a proc as the optional option. This will add a validator to the parent node that makes sure thar the 
key is present if the optional condition does not apply.

```ruby
schema = NxtSchema.schema(:contact) do
  required(:first_name, :String)
  required(:last_name, :String)
  node(:email, :String, optional: ->(node) { node.up[:last_name].input == 'Robecke' })
end

result = schema.apply(input: { first_name: 'Andy', last_name: 'Other' })
result.errors # => {"contact"=>["Required key :email is missing"]}

result = schema.apply(input: { first_name: 'Andy', last_name: 'Robecke' })
result.errors # => {}
```  

#### Combining Schemas

You can also simply reuse a schema by passing it to the node method as the type of a node. When doing so the schema 
will be cloned with the same options and configuration as the schema passed in. 

```ruby
ADDRESS = NxtSchema.schema(:address) do
  required(:street, :String)
  required(:town, :String)
  required(:zip_code, :String)
end 

PERSON = NxtSchema.schema(:person) do
  required(:first_name, :String)
  required(:last_name, :String)
  optional(:address, ADDRESS)
end
```

### Types

The type system is built with dry-types from the amazing https://dry-rb.org eco system. Even though dry-types also
offers features such as default values for types as well as maybe types, these features are built directly into 
NxtSchema. 

Please note that Dry.rb also has a gem for schemas: https://dry-rb.org/gems/dry-schema and another one dedicated to 
validations explicitly https://dry-rb.org/gems/dry-validation. You should probably go and check those out! NxtSchema
is trying to implement a simpler solution that is easy to understand yet powerful enough for most tasks.  

In NxtSchema every node has a type and you can either provide a symbol that will be resolved 
through the type system of the schema or you can directly provide an instance of dry type and thus use your 
custom types. This means you can basically build any kind of objects such as structs and models from your data and 
you are not limited to just hashes arrays and primitives.  

#### Default type system

You can tell your schema which default type system it should use. Dry-Types comes with a few built in type systems.
Per default NxtSchema will use nominal types if not specified otherwise. If the type cannot be resolved from the default
type system that was specified NxtSchema will always fallback to nominal types. In theory you can provide
a separate type system per node if that's what you need. 
                               
```ruby
NxtSchema.root do
  required(:test, :String) # The :String will resolve to NxtSchema::Types::Nominal::String
end

NxtSchema.root(type_system: NxtSchema::Types::JSON) do
  required(:test, :Date) # The :Date will resolve to NxtSchema::Types::JSON::Date
  # When the type does not exist in the default type system (there is non JSON::String) we fallback to nominal types
  required(:test, :String) 
end
```

#### NxtSchema.params

NxtSchema.params will give you a schema as root node with NxtSchema::Types::Params as default type system.
This is suitable to validate and coerce your query params. 

```ruby
NxtSchema.params do
  required(:effective_at, :DateTime) # would resolve to Types::Params::DateTime 
  required(:test, :String) # The :String will resolve to NxtSchema::Types::Nominal::String
  required(:advanced, NxtSchema::Types::Params::Bool) # long version of required(:advanced, :Bool)
end
```

#### Custom types

You can also register custom types. In order to check out all the cool things you can do with dry types you should 
check out dry-types on https://dry-rb.org. But here is how you can add a type to the `NxtSchema::Types` module. 

```ruby
NxtSchema.register_type(
  :MyCustomStrippedString,
  NxtSchema::Types::Strict::String.constructor(->(string) { string&.strip })
)

# once registered you can use the type in your schema

NxtSchema.root(:company) do
  required(:name, :MyCustomStrippedString)
end
```

### Values

#### Default values

```ruby
# Define default values as options or with the default method
required(:test, :DateTime).default(-> { Time.current })
required(:test, :String, default: 'Andy')
```

#### Maybe values 

With maybe you can allow your values to be of a certain type and halt conversion. **Note: This means that your output
will simply be set to the input without coercing the value!**

```ruby
# Define maybe values (values that do not match the type)
required(:test, :String).maybe(:nil?)

nodes(:tests).maybe(:empty?) do # will allow the collection to be empty
  required(:test, :String)
end

```  

### Validations

NxtSchema comes with a simple validation system and ships with a small set of useful validators. Every node in a schema
implements the `:validate` method. Similar to ActiveModel::Validations it allows you to simply add errors to a node
based on some condition. When the node is yielded to your validation proc you have access to the nodes input with
`node.input` and `node.index` when the node is within a collection of nodes as well as `node.name`. Furthermore you have 
access to the context that was passed in when defining the schema or passed to the apply method later.

```ruby
  # Simple custom validation
  required(:test, :String).validate(-> (node) { node.add_error("#{node.input} is not valid") if node.input == 'not allowed' })
  # Built in validations
  required(:test, :String).validate(:attribute, :size, ->(s) { s < 7 }) 
  required(:test, :String).validate(:equal_to, 'same') 
  required(:test, :String).validate(:excluded_in, %w[not_allowed]) # excluded in the target: %w[not_allowed]
  required(:test, :String).validate(:included_in, %w[allowed]) # included in the target: %w[allowed]
  required(:test, :Array).validate(:excludes, 'excluded') # array value itself must exclude 'excluded' 
  required(:test, :Array).validate(:includes, 'included') # array value itself must include 'included'
  required(:test, :Integer).validate(:greater_than, 1) 
  required(:test, :Integer).validate(:greater_than_or_equal, 1) 
  required(:test, :Integer).validate(:less_than, 1) 
  required(:test, :Integer).validate(:less_than_or_equal, 1) 
  required(:test, :String).validate(:pattern, /\A.*@.*\z/) 
  required(:test, :String).validate(:query, :present?) 
```

#### Custom validators

You can also register your custom validators. Therefore you can simply implement a class that returns a lambda on build.
This lambda will be called with the node the validations runs on and it's input value. Except this, you are free in 
how your validator can be used. Check out the specs for some examples. 

```ruby
class MyCustomExclusionValidator
  def initialize(target)
    @target = target
  end

  attr_reader :target

  def build
    lambda do |node, value|
      if target.exclude?(value)
        true
      else
        node.add_error("#{target} should not contain #{value}")
        false # validators must return false in the bad case (add_error already does this as per default)
      end
    end
  end
end

# Register your validators  
NxtSchema.register_validator(MyCustomExclusionValidator, :my_custom_exclusion_validator)

# and then simply reference it with the key you've registered it
schema = NxtSchema.root(:company) do
  requires(:name, :String).validate(:my_custom_exclusion_validator, %w[lemonade])
end

schema.apply(name: 'lemonade').valid? # => false
```

#### Validation messages

- Allow to specify a path to translations
- Add translated errors
- Interpolate with actual vs. expected 

#### Combining validators with custom logic

`node(:test, String).validate(...)` basically adds a validator to the node. Of course you can add multiple validators.
But that means that they will all be executed and errors aggregated. If you want your validator to only run in case 
another was false, you can use `:validat_with do ... end` in order to combine validators based on custom logic. 

 ```ruby
NxtSchema.root do
  required(:test, :Integer).validate_with do
    validator(:greater_than, 5) &&
      validator(:greater_than, 6) &&
      validator(:greater_than, 7)
  end
end
```

This has one drawback however. Let's say your test value is 4. This would only run your first validator and then exit 
from the logic since validators are combined with &&. In this example it might not make much sense, but it basically 
means that you might not have the full validation errors when combining validations with `:validate_with` 


### Schema options
 
#### Optional keys strategies

Schemas in NxtSchema only look at the keys that you have defined in your schema, others are ignored per default.
You can change this behaviour by providing a strategy for the `:additional_keys` option. 

```ruby
# This will simply ignore any other key except test 
NxtSchema.root(additional_keys: :ignore) do
  required(:test, :String) 
end

# This would give you an error in case you apply anything other than { test: '...' }
NxtSchema.root(additional_keys: :restrict) do
  required(:test, :String) 
end

# This will merge other keys into your output
schema = NxtSchema.root(additional_keys: :allow) do
  required(:test, :String) 
end

schema.apply(input: {test: 'getsafe', other: 'Heidelberg'})
schema.valid? # => true
schema.value # => { test: 'getsafe', other: 'Heidelberg' }
```

#### Transform keys

You may want to transform the keys from your input. Therefore specify the transform_keys option. This might be useful
when you want your schema to return only symbolized keys for example. 

```ruby
schema = NxtSchema.root(transform_keys: ->(key) { key.to_sym}) do
  required(:test, :String)
end

schema.apply(input: { 'test' => 'getsafe' }) # => {:test=>"getsafe"}
schema.apply(input: { test: 'getsafe' }) # => {:test=>"getsafe"}
``` 

#### Adding meta data to nodes

You want to give nodes an ID or some other meta data? You can use the meta method on nodes for adding additional 
information onto any node.  

```ruby
schema = NxtSchema.root do
  ERROR_MESSAGES = {
    test: 'This is always broken'
  }

  required(:test, :String).meta(ERROR_MESSAGES).validate ->(node) { node.add_error(node.meta.fetch(node.name)) }
end

schema.apply(input: { test: 'getsafe' }) 
schema.error #  {"root.test"=>["This is always broken"]}
```

#### Contexts

# TODO

##### Build time

##### Apply time


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/getand.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
