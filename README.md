# MOSAIK
[![Continuous Integration](https://github.com/floriandejonckheere/mosaik/actions/workflows/ci.yml/badge.svg)](https://github.com/floriandejonckheere/mosaik/actions/workflows/ci.yml)
![Release](https://img.shields.io/github/v/release/floriandejonckheere/mosaik?label=Latest%20release)

Modular Optimization to Service-oriented Architecture Implementation Kit (MOSAIK)

MOSAIK is an automated toolkit for software architects and developers to convert monolithic applications into service-oriented architectures.
It provides a set of tools to analyze, extract, and refactor monolithic applications into modular monoliths or microservices.

## Prerequisites

MOSAIK requires your application to use the [Zeitwerk](https://github.com/fxn/zeitwerk) code loader, and to adhere to Zeitwerk's [file structure](https://github.com/fxn/zeitwerk#file-structure) and [naming conventions](https://github.com/fxn/zeitwerk#zeitwerkinflector).
At the moment, only Ruby 3.3 is supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "mosaik"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mosaik

Generate the binstubs:

    $ bundle binstubs mosaik

## Usage

In the root directory of your project, create a new configuration file:

```bash
$ mosaik init
```

This will create a new `mosaik.yml` configuration file in the current directory.
The `mosaik.yml` file tells MOSAIK which files should be included or excluded from the decomposition.

Using MOSAIK is a three-step process:

### Collect

The `collect` command collects information about the application to analyze and extract services from.

```bash
$ mosaik collect --help
```

### Decompose

The `decompose` command decomposes the application into services.

```bash
$ mosaik decompose --help
```

### Analyze

The `analyze` command analyzes the given decomposition, and evaluates the quality of the decomposition.

```bash
$ mosaik analyze --help
```

## Releasing

To release a new version, update the version number in `lib/mosaik/version.rb`, update the changelog, commit the files and create a git tag starting with `v`, and push it to the repository.
Github Actions will automatically run the test suite, build the `.gem` file and push it to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/floriandejonckheere/mosaik](https://github.com/floriandejonckheere/mosaik). 

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
