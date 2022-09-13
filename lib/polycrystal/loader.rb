# frozen_string_literal: true

module Polycrystal
  class Loader
    attr_reader :compiler

    def initialize(compiler:)
      @compiler = compiler
    end

    def load
      compiler.prepare
      library = compiler.execute
      load_library(library) # load_library is defined in C file
    end
  end
end
