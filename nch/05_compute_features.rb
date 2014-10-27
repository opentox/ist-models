#!/usr/bin/env ruby

require "./config.rb"

require "bundler"
Bundler.require

DATA.each do |d|
  $stderr.puts "\ndataset name #{d}"

  next if d=="LOAEL-mg"

  f = new_feature_dataset_uri(d)
  puts "Feature dataset: "+f

#  dataset = OpenTox::Dataset.new 
#  dataset.upload File.join("data/03/#{d}_uniq.csv")
#  puts "Dataset: "+dataset.uri
#  info(dataset)
#
#  feature_names =  File.open("data/04/#{d}.feature_names","r").read.chomp.split(",")
#  puts "Features: "+feature_names.inspect
#
#  puts feature_dataset_uri = wait_for_task(OpenTox::RestClientWrapper.post("http://localhost:8081/algorithm/descriptor/physchem",{:dataset_uri => dataset.uri, :descriptors => feature_names}))
#  puts "Feature dataset: "+feature_dataset_uri
#  info(OpenTox::Dataset.new(feature_dataset_uri))

  csv_string = OpenTox::Dataset.new(f).to_csv(true)
  File.open("data/05/#{d}_new-features.csv","w").puts csv_string
  puts "Feature dataset written to data/05/#{d}_new-features.csv"
  puts ""

end
