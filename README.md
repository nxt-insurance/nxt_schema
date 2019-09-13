# NxtSchema

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nxt_schema`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO:
- Master Plan
    => apply should take keyword args [X]
    => Add level to each node [X]
    => Add a second errors_store next to schema_errors 
        => node_errors should probably be renamed to schema_errors [X]
        => add validation_errors next to schema_errors [X]
            => validation_errors should be initialized with schema_errors
        => collect all nodes with validations in a single all_nodes store
    
- Test all methods of all nodes
- Merge errors of array nodes with multiple schemas
- Collect namespaced errors from schema_errors when walking the tree
- Implement root and roots on root node
- Implement maybe
- Implement optional keys for all nodes
- Validator Registry
- Type Registry
- Structure Errors
- Instance exec if block does not accept argument
- Enforce uniqueness of names of multiple schemas in array nodes?!
- Implement default values - Should also be checked against the schema
- Can we have nodes in the schema depending on others => One node is required / optional if the other is present or contains a certain value?
 

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

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nxt_schema.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
