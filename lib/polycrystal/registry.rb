# frozen_string_literal: true

require 'singleton'
require 'forwardable'

module Polycrystal
  class Registry
    extend Forwardable
    include Singleton
    include Enumerable

    CrystalModule = Struct.new(:path, :file, :modules, keyword_init: true)

    attr_reader :modules

    def_delegators :@modules, :each

    def initialize
      @modules = []
    end

    def register(path:, file: nil, modules: nil, unshift: false)
      raise ArgumentError, 'include file is requred to wrap modules' if file.nil? && !modules.nil?

      existing = find_module(file: file, path: path)
      if existing
        existing.modules += modules if modules
      else
        new_mod = CrystalModule.new(
          path: path,
          file: file,
          modules: modules
        )
        unshift ? @modules.unshift(new_mod) : @modules.push(new_mod)
      end
    end

    def find_module(path:, file:)
      modules.find { |mod| mod.path == path && mod.file == file }
    end

    class << self
      extend Forwardable

      def_delegators :instance, :register, :modules
    end
  end
end
