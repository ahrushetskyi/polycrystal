# frozen_string_literal: true

module Polycrystal
  class Loader
    attr_reader :build_path, :registry

    def initialize(build_path:, registry: Polycrystal::Registry.instance)
      @build_path = build_path
      @registry = registry
    end

    def load
      compiler = Polycrystal::Compiler.new(
        build_path: build_path,
        registry: registry
      )
      compiler.prepare
      library = compiler.execute
      load_library(library) # load_library is defined in C file
    end
  end
end
