#!/usr/bin/env ruby

require "./config.rb"

require "bundler"
Bundler.require

res = YAML.load("---
- :min_sim: 0.65
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/73
  :r_square: 0.28572954365573644
  :unpredicted: '3'
  :features: all-pc-features
- :min_sim: 0.65
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/74
  :r_square: 0.20115321576362188
  :unpredicted: '3'
  :features: new-pc-features
- :min_sim: 0.65
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/76
  :r_square: 0.013357820165398548
  :unpredicted: '5'
  :features: ob-pc-features")

min_train = [nil,0.1,0.2] #,0.3,0.4,0.5]

all = nil
s = [ "feat\\train" ]
min_train.each do |m|
  s << (m==nil ? 0.0 : m).to_s
end
out = [s]

res.each do |r|
#  s = [ r[:min_sim].to_s ]
 s = [ r[:features].to_s ]
  stats = OpenTox::Crossvalidation.find(r[:cv]).statistics
  all = stats.metadata[RDF::OT.numInstances.to_s].to_i unless all
  min_train.each do |m|
    data = (m==nil ? stats.metadata : stats.filter_metadata(m))
    v =  sprintf("%.3f",data[RDF::OT.regressionStatistics.to_s][RDF::OT.rSquare.to_s])
    v << "("
    v << sprintf("%2d",(all - (data[RDF::OT.numInstances.to_s].to_i-data[RDF::OT.numUnpredicted.to_s].to_i)))
    v << ")"
    s << v
  end
  out << s
end


def print_2d_array(a, cs=15)
  report = []   
  report << a.enum_for(:each_with_index).map { |ia, i|
    ia.map{|e| "%#{cs}s" % e}.join(" | ") }
  puts report.join("\n")
end

print_2d_array out
