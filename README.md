# Polycrystal

Integrate Crystal code into ruby sing the [Anyolite](https://github.com/Anyolite/anyolite)

Right now it uses a forked with tiny modifications to linking and initialization: https://github.com/ahrushetskyi/anyolite

## Installation

### Now (tested only on MacOS and ruby 3.0.4)

Clone repo with submodules

```bash
git clone git@github.com:ahrushetskyi/polycrystal.git
# or
git clone https://github.com/ahrushetskyi/polycrystal.git
```

Compile C extension and Anyolite glue objects

```bash
cd ext/polycrystal
ruby extconf.rb
make
```

Check out sample app:

```bash
# from repository root
cd sample_project
irb -r ./sample
```

then following should work in the irb console:

```ruby
CrystalModule::CrystalClass.new.crystal_method
CrystalModule::CrystalClass.new.return_object
CrystalModule::CrystalClass.new.return_object.some_method
CrystalModule::CrystalClass.new.recv_arg(arg: 42)
```

### Planned

Add this line to your application's Gemfile:

```ruby
gem 'polycrystal'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polycrystal

## Usage

```ruby
require 'polycrystal'

Polycrystal::Registry.register(
    # directory with crystal files, added to crystal CRYSTAL_PATH
    path: File.expand_path("#{__dir__}/crystal"),
    # file, that should be loaded. Transformed into `require "sample"` in crystal entrypoint, should be accessible from :path
    file: 'sample.cr', 
    # This gets wrapped by Anyolite
    modules: ['CrystalModule'] 
)

# directory for entrypoint and compiled library. 
build_path = File.expand_path("#{__dir__}/build") 
FileUtils.mkdir_p(build_path)

# cpmpile and load 
# should be called once, after all Polycrystal::Registry#register calls
Polycrystal::Loader.new(build_path: build_path).load
```

## TODO

1. Test suite
2. Code should not be recompiled if it was not changed
3. Ability to precompile all code on demand, e.g. for Docker images
4. make shards work. Anyolite may be loaded from shards, if my patches are merged, or better alternatives implemented

## Development

```bash
git clone git@github.com:ahrushetskyi/polycrystal.git
# or
git clone https://github.com/ahrushetskyi/polycrystal.git
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/polycrystal.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
