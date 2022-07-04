<p align="center">
    <br />
    <a href="https://dashx.com"><img src="https://raw.githubusercontent.com/dashxhq/brand-book/master/assets/logo-black-text-color-icon@2x.png" alt="DashX" height="40" /></a>
    <br />
    <br />
    <strong>Your All-in-One Product Stack</strong>
</p>

<div align="center">
  <h4>
    <a href="https://dashx.com">Website</a>
    <span> | </span>
    <a href="https://dashxdemo.com">Demos</a>
    <span> | </span>
    <a href="https://docs.dashx.com/developer">Documentation</a>
  </h4>
</div>

<br />

# dashx-ruby

_DashX SDK for Ruby_

## Install

Add this line to your application's Gemfile:

```ruby
gem 'dashx'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install dashx
```

## Usage

For detailed usage, refer to the [documentation](https://docs.dashx.com/developer).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dashxhq/dashx-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dashxhq/dashx-ruby/blob/master/CODE_OF_CONDUCT.md).

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Publishing

We use the amazing [gem-release](https://github.com/svenfuchs/gem-release) for releases.

**Installation**

```
gem install gem-release
```

**Deploying a new version**

```
git checkout master // Ensure you're in the master branch
gem bump -v minor // Automatically sets the version number, commits
git push origin master // Push the version bump commit
gem release
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dashx project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/dashx/blob/master/CODE_OF_CONDUCT.md).
