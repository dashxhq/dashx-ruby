# DashX

DashX SDK for Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dashx'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dashx

## Usage

```ruby
require 'dashx'

DashX.deliver({ to: 'johndoe@example.com' })
```

### Configuration

```ruby
DashX.configure do |config|
  config.public_key = ENV['DASHX_PUBLIC_KEY']
  config.private_key = ENV['DASHX_PRIVATE_KEY']
end
```

### Deliver

```ruby
DashX.deliver({
  to: 'John Doe <john@example.com>',
  body: 'Hello World!'
});
```

`deliver` can accept multiple recipients like so:

```ruby
DashX.deliver({
  to: ['John Doe <john@example.com>','admin@example.com', 'sales@example.com>'],
  body: 'Hello World!'
});
```

### Identify

You can use `identify` to update user info associated with the provided `uid`

```ruby
DashX.identify('uid_of_user', {
  first_name: 'John',
  last_name: 'Doe',
  email: 'johndoe@email.com',
  phone: '+1-234-567-8910'
})
```

##### For Anonymous User

When you don't know the `uid` of the user, you can still use `identify` to add info to the user like so:

```ruby
DashX.identify({
  first_name: 'John',
  last_name: 'Doe',
  email: 'johndoe@email.com',
  phone: '+1-234-567-8910'
})
```

`identify` will automatically append a pseudo-random `anonymous_uid` in this case.

### Track

```ruby
DashX.track('event_name', 'uid_of_user', { hello: 'world' })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dashxhq/dashx-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dashxhq/dashx-ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dashx project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dashx/blob/master/CODE_OF_CONDUCT.md).
