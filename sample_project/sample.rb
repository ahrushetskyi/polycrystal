# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'polycrystal'

Polycrystal::Registry.register(
  path: File.expand_path("#{__dir__}/crystal"),
  file: 'sample.cr',
  modules: ['CrystalModule']
)

build_path = File.expand_path("#{__dir__}/build")

FileUtils.mkdir_p(build_path)

Polycrystal::Loader.new(build_path: build_path).load
