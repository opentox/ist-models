#!/usr/bin/env ruby

require "./config.rb"

require "bundler"
Bundler.require

res = YAML.load("---
- :min_sim: 0.0
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/54
  :r_square: 0.45370176424121433
  :unpredicted: '0'
- :min_sim: 0.1
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/55
  :r_square: 0.4595956327160562
  :unpredicted: '0'
- :min_sim: 0.2
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/56
  :r_square: 0.4277448070809924
  :unpredicted: '0'
- :min_sim: 0.3
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/57
  :r_square: 0.44307217405529253
  :unpredicted: '0'
- :min_sim: 0.4
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/58
  :r_square: 0.4536563787494641
  :unpredicted: '0'
- :min_sim: 0.5
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/59
  :r_square: 0.4461298986550688
  :unpredicted: '0'
- :min_sim: 0.6
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/60
  :r_square: 0.4720263367371236
  :unpredicted: '1'
- :min_sim: 0.7
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/61
  :r_square: 0.5057497593073133
  :unpredicted: '15'
- :min_sim: 0.8
  :min_train: 0.0
  :cv: http://localhost:8087/validation/crossvalidation/62
  :r_square: 0.5505636328364947
  :unpredicted: '65'
")

all=182

min_train = [nil,0.1,0.2,0.3,0.4,0.5]

s = [ "sim\\train" ]
min_train.each do |m|
  s << (m==nil ? 0.0 : m).to_s
end
out = [s]

res.each do |r|
  s = [ r[:min_sim].to_s ]
  stats = OpenTox::Crossvalidation.find(r[:cv]).statistics
  min_train.each do |m|
    data = (m==nil ? stats.metadata : stats.filter(m))
    v =  sprintf("%.3f",data[RDF::OT.regressionStatistics.to_s][RDF::OT.rSquare.to_s])
    v << "("
    v << sprintf("%2d",(all - (data[RDF::OT.numInstances.to_s].to_i-data[RDF::OT.numUnpredicted.to_s].to_i)))
    v << ")"
    s << v
  end
  out << s
end


def print_2d_array(a, cs=10)
  report = []   
  report << a.enum_for(:each_with_index).map { |ia, i|
    ia.map{|e| "%#{cs}s" % e}.join(" | ") }
  puts report.join("\n")
end

print_2d_array out
