# Sn::Foil

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/snfoil`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'snfoil'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install snfoil

## Usage


### Major Components

#### Model
#### Policy
#### Searcher

## Contexts
Contexts are groupings of common actions that a certain entity can perform.

### Data

### Actions

SnFoil Contexts handle basic CRUD through a few different actions

<table>
    <thead>
        <th>Action</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td>Build</td>
            <td>
                The action on setting up a model but not persiting.
                <div>
                    <i>Author's note:</i> So far I have just been using this so factories in testing follow the same setup logic as a context would.
                </div>
            </td>
        </tr>
        <tr>
            <td>Create</td>
            <td>The action of setting up a model and persisting it.</td>
        </tr>
        <tr>
            <td>Update</td>
            <td>The action of finding a pre-existing model and updating the attributes.</td>
        </tr>
        <tr>
            <td>Destroy</td>
            <td>The action of finding a pre-existing model and destroying it.</td>
        </tr>
        <tr>
            <td>Show</td>
            <td>The action of finding a pre-existing model by an identifier.</td>
        </tr>
        <tr>
            <td>Index</td>
            <td>The action of finding a pre-existing models by using a searcher.</td>
        </tr>
    </tbody>
</table>

### Methods
Methods allow users to create inheritable actions that occur in a specific order.  Methods will always run before their hook counterpart.  Since these are inheritable, you can chain needed actions all the way through the parent heirarchy by using the `super` keyword. 

<strong>Important Note</strong> Methods <u>always</u> need to return the options hash at the end.

<i>Author's opinion:</i> While simplier than hooks, they do not allow for as clean of a composition as hooks.

#### Example

```ruby
# Call the webhooks for third party integrations
# Commit business logic to internal process
def after_create_success(**options)
    options = super

    call_webhook_for_model(options[:object])
    finalize_business_logic(options[:object])

    options
end

# notify error tracker
def after_create_error(**options)
    options = super

    notify_errors(options[:object].errors)

    options
end
```

### Hooks
Hooks make it very easy to compose multiple actions that need to occur in a specific order.  You can have as many repeated hooks as you would like.  This makes defining single responsibility hooks very simple, and they will get called in the order they are defined.  The major downside of hooks are that they are currently not inheritable.

<strong>Important Note</strong> Hooks <u>always</u> need to return the options hash at the end.

#### Example
Lets take the Method example and make it into hooks instead.
```ruby
# Call the webhooks for third party integrations
after_create_success do |options|
    call_webhook_for_model(options[:object])
    options
end

# Commit business logic to internal process
after_create_success do |options|
    finalize_business_logic(options[:object])
    options
end

# notify error tracker
after_create_error do |options|
    notify_errors(options[:object].errors)
    options
end
```

<table>
    <thead>
        <th>Name</th>
        <th>Timing</th>
        <th>Description</th>
    </thead>
    <tbody>
        <tr>
            <td>setup</td>
            <td>-Always at the beginning</td>
            <td>Primarily used for basic setup logic that always needs to occur</td>
        </tr>
        <tr>
            <td>setup_&lt;action&gt;</td>
            <td>-Before the object has been found or created</td>
            <td>Primarily used for basic setup logic that only needs to occur for certain actions</td>
        </tr>
        <tr>
            <td>before_&lt;action&gt;</td>
            <td>
                <div>-After the object has been found or created</div>
                <div>-Before the object has been persisted/altered</div>
            </td>
            <td></td>
        </tr>
        <tr>
            <td>after_&lt;action&gt;_success</td>
            <td>-After the object has been successfully been persisted/altered</td>
            <td></td>
        </tr>
        <tr>
            <td>after_&lt;action&gt;_failure</td>
            <td>-After an error has occured persisting/altering the object</td>
            <td></td>
        <tr>
            <td>after_&lt;action&gt;</td>
            <td>-Always at the end</td>
            <td></td>
        </tr>
        </tr>
    </tbody>
<table>

### Call Order

The call order for actions is extremely important because SnFoil passes the options hash throughout the entire process.  So any data you may need down the call order can be added earlier in the stack.

<table>
    <thead>
        <tr>
            <th rowspan="2">Action</th>
            <th colspan="2">Order</th>
        </tr>
        <tr>
            <th>Type</th>
            <th>Name</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan="5">Build</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_build</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_build</td>
        </tr>
        <tr><td rowspan="25">Create</td></tr>
        <tr>
            <td>Method</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_build</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_build</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_create</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_create</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>before_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>before_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>before_create</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>before_create</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_change_success</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_change_success</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_create_success</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_create_success</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_change_failure</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_change_failure</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_create_failure</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_create_failure</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>after_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>after_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>after_create</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>after_create</td>
        </tr>
        <tr><td rowspan="23">Update</td></tr>
        <tr>
            <td>Method</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_update</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_update</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>before_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>before_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>before_update</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>before_update</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_change_success</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_change_success</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_update_success</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_update_success</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_change_failure</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_change_failure</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_update_failure</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_update_failure</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>after_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>after_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>after_update</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>after_update</td>
        </tr>
        <tr><td rowspan="23">Destroy</td></tr>
        <tr>
            <td>Method</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_destroy</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_destroy</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>before_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>before_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>before_destroy</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>before_destroy</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_change_success</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_change_success</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_destroy_success</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_destroy_success</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_change_failure</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_change_failure</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td><i>*after_destroy_failure</i</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td><i>*after_destroy_failure</i</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>after_change</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>after_change</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>after_destroy</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>after_destroy</td>
        </tr>
        <tr>
            <td rowspan="5">Show</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_show</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_show</td>
        </tr>
        <tr>
            <td rowspan="5">Index</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup</td>
        </tr>
        <tr>
            <td>Method</td>
            <td>setup_index</td>
        </tr>
        <tr>
            <td>Hooks</td>
            <td>setup_index</td>
        </tr>
    </tbody>
<table>

<div>
* only occurs depeding on the success or failure of the action
</div>

## Policies

## Searchers


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/snfoil. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sn::Foil project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/snfoil/blob/master/CODE_OF_CONDUCT.md).
