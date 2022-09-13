# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'polycrystal'

Polycrystal::Registry.register(
  path: File.expand_path("#{__dir__}/crystal"),
  file: 'sample.cr',
  modules: ['CrystalModule']
)

Polycrystal.load
