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

# cpmpile and load 
# should be called once, after all Polycrystal::Registry#register calls
Polycrystal.load
```

Set custom properties
```ruby
# directory for crystal entrypoint and compiled library. 
build_path = File.expand_path("#{__dir__}/build") 
FileUtils.mkdir_p(build_path)


Polycrystal.load(
    # directory for crystal entrypoint and compiled library. 
    build_path: build_path,
    # used to find lib with installed shards. SHARDS_INSTALL_PATH is used if present
    shardfile: "./crystal/shard.yml", 
    # Polycrystal::NO_PRECOMPILE - compile everytime
    # Polycrystal::LAZY_COMPILE - compile if not yet compiled
    # Polycrystal::REQUIRE_AOT - not compile, require to be precompiled
    precompile: Polycrystal::LAZY_COMPILE, # by default
)
```

## TODO

1. Test suite
2. Remove C code from this extension.
   * C code is not required. Crystal code may be directly compiled to extension and loaded using standard `requre`
   * To achieve that, anyolite glue files should be compiled to object files and linked to existing ruby correctly. I got segfault when I built glue files outside of ruby extension
2. Code should not be recompiled if it was not changed
   * Rudimentary implementation is present, but more stable is preferrable: `Polycrystal.load(precompile: Polycrystal::LAZY_COMPILE)`
3. Ability to precompile all code on demand, e.g. for Docker images
   * It is possible to do that right now by calling `Polycrystal.load(precompile: Polycrystal::LAZY_COMPILE)` in separate command, while loading Crystal module using `Polycrystal.load(precompile: Polycrystal::REQUIRE_AOT)`
4. make shards work. DONE, except:
   * Anyolite can't be loaded from shards, because it's postinstall script downloads and compiles it's own mruby 

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
