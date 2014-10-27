#!/usr/bin/env ruby

require "csv"
require "uri"

require "./config.rb"

require "bundler"
Bundler.require

feature_names = OpenTox::RestClientWrapper.get("http://localhost:8081/algorithm/descriptor/physchem/list_values").split("\n")
puts "derived #{feature_names.size} features from algorithm service"

DATA.each do |d|
  $stderr.puts "\ndataset name #{d}"

  next if d=="LOAEL-mg"
  
  orig_features = nil
  CSV.foreach("data/02/#{d}_orig-features.csv") do |row|
    raise "first column is not InChI: #{row}" unless row[0]=="InChI"
    orig_features = row[1..-1]
    break
  end
  #puts orig_features.inspect
  #puts "->"

  matches = []
  orig_features.each do |f|
    m = []
    feature_names.each do |n|
      m << n if n=~/#{f}$/
    end
    raise "could not match #{f}: #{m.inspect}" unless m.size==1
    matches += m
  end
  #matches.sort!
  # puts matches.inspect
  #  puts ""

  File.open("data/04/#{d}.feature_names","w").puts matches.join(",")
  $stderr.puts "written #{matches.size} features to data/04/#{d}.feature_names"
end


