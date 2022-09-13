# frozen_string_literal: true

require 'polycrystal/version'
require 'polycrystal/polycrystal'
require 'polycrystal/registry'
require 'polycrystal/compiler'
require 'polycrystal/loader'

module Polycrystal
  class Error < StandardError; end

  PRECOMPILE = [
    NO_PRECOMPILE = :no_precompile,
    LAZY_COMPILE = :lazy_compile,
    REQUIRE_AOT = :require_compiled
  ].freeze

  def self.load(build_path: nil, shardfile: nil, precompile: LAZY_COMPILE)
    build_path ||= "#{Dir.pwd}/build"
    shardfile ||= "#{Dir.pwd}/shard.yml" if File.exist?("#{Dir.pwd}/shard.yml")
    shardfile ||= "#{Dir.pwd}/crystal/shard.yml" if File.exist?("#{Dir.pwd}/crystal/shard.yml")

    compiler = Polycrystal::Compiler.new(build_path: build_path, shardfile: shardfile, precompile: precompile)
    Polycrystal::Loader.new(compiler: compiler).load
  end
end
