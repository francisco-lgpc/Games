ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Optional-02-Gosu-Game', 'bin/gameRun')

require 'bundler/setup'

require_relative "../lib/game.rb"
