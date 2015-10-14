#!/usr/bin/env ruby

require_relative '../../app/models/shortened_url'
require 'rake'

task :prune do
  ShortenedUrl.prune(90)
end
