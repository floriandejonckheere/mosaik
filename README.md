# MOSAIK
[![Continuous Integration](https://github.com/floriandejonckheere/mosaik/actions/workflows/ci.yml/badge.svg)](https://github.com/floriandejonckheere/mosaik/actions/workflows/ci.yml)
![Release](https://img.shields.io/github/v/release/floriandejonckheere/mosaik?label=Latest%20release)

Modular Optimization to Service-oriented Architecture Implementation Kit (MOSAIK)

MOSAIK is a toolkit for software architects and developers to convert monolithic applications into service-oriented architectures.
It provides a set of tools to analyze, extract, and refactor monolithic applications into modular monoliths or microservices.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "mosaik"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mosaik

## Usage

## Releasing

To release a new version, update the version number in `lib/mosaik/version.rb`, update the changelog, commit the files and create a git tag starting with `v`, and push it to the repository.
Github Actions will automatically run the test suite, build the `.gem` file and push it to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/floriandejonckheere/mosaik](https://github.com/floriandejonckheere/mosaik). 

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
