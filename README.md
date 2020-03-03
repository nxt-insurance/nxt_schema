# NxtSchema

TODO:    

- Add Options class that knows what kind of options are allowed and exclude each other
- Interface to register custom types / custom validators
- Implement proper schema and validation error system that would be capable of I18n and custom error messages
- Test the different scenarios of merging schemas array, hash, ...
- Test all methods of all nodes
    => Structure tests by nodes and method
    
- Structure Errors 
- NxtSchema::Json => Use json types, maybe even parse Json with Oj
- Should we allow to pass in meta data to any node - would be kind of nice to be able to access it
    required(:name, :String).meta(internal: true, required_for_pricing: true) 
    required(:tariff, Enum()).meta(internal: true, required_for_pricing: true) 
 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nxt_schema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nxt_schema

## Usage

```ruby
# Schema with hash root
schema = NxtSchema.root(:company) do 
  requires(:name, :String)  
  requires(:value, :Integer).maybe(nil)  
  present(:stock_options, :Bool).default(false)
  
  schema(:address) do
    requires(:street, :String)
    requires(:street_number, :Integer)
  end
    
  nodes(:employees) do
    hash(:employee) do
      POSITIONS = %w[senior junior intern]

      requires(:first_name, :String)
      requires(:last_name, :String)
      optional(:email, :String).validate(:format, /\A.*@.*\z/)
      requires(:position, NxtSchema::Types::Enums[*POSITIONS])
    end
  end
end
  
# Schema with array root
schema = NxtSchema.roots(:companies) do
  schema(:company) do
    requires(:name, :String)  
    requires(:value, :Integer).maybe(nil)
  end
end

schema.apply(your: 'values here')
schema.errors # { 'name.spaced.key': ['all the errors'] }
```

### DSL

Create a new schema with `NxtSchema.root { ... }` or  in case you have an array node as root, 
use `NxtSchema.roots { ... }`. Within the schema you can create node simply with the `node(name, type_or_node, **options)` 
method. Each node requires a name and a type and accepts additional options. Node are required per default. 
But you can make them optional by providing the optional option.  

#### Nodes

```ruby
NxtSchema.root do
  node(:first_name, :String)
  node(:last_name, :String, optional: true)
  node(:email, :String, presence: true)
end
```

In order to make the schema more readable you can make use of several predicate aliases to create required, optional or 
(omni)present nodes.  

#### Predicate aliases

```ruby
NxtSchema.root do
  required(:first_name, :String)
  optional(:last_name, :String)
  present(:email, :String)
end
```

### Nodes

The following types of nodes exist

#### Schema Nodes

```ruby
# Create schema nodes with:
node(:test, :Schema) do ... end
schema(:test) do ... end
hash(:test) do ... end
```

#### Collection Nodes

```ruby
# Create collection (array) nodes with:
node(:test, :Collection) do ... end
nodes(:test) do ... end
array(:test) do ... end
```

#### Leaf Nodes

```ruby
# Create leaf nodes with, or with one of the predicat aliases above
node(:test, :String) do ... end
```

#### Struct Nodes

```ruby
# Create structs from hash nodes 
struct(:test) do ... end  
```

### Types

The type system is built with dry-types from the amazing https://dry-rb.org/ eco system. Even though dry-types also
offers features such as default values for types as well as maybe types, these features are built directly into 
NxtSchema.

#### Default values

```ruby
# Define default values as options or with the default method
node(:test, :String).default(value_or_proc)
node(:test, :String, default: value_or_proc) do ... end
```

#### Maybe values

```ruby
# Define maybe values (values that do not match the type)
node(:test, :String).maybe(value_or_proc)
node(:test, :String, maybe: value_or_proc) do ... end
```  

### Schema options

#### Default type system
 
#### Optional keys strategies

#### Transform keys

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nxt_schema.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
