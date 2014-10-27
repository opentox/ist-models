#!/usr/bin/env ruby

require "csv"
require "uri"

require "./config.rb"

unless ARGV.size==3 and (DATA-["LOAEL-mg"]).include?(ARGV[0]) and ARGV[1]=~/features|compounds/
  $stderr.puts "\nfirst-param: dataset-name from "+(DATA-["LOAEL-mg"]).inspect
  $stderr.puts "second-param:  features|compounds"
  $stderr.puts "third-param: <num>"
  $stderr.puts ""
  $stderr.puts "second param specifies if features or compounds that differ should be printed"
  $stderr.puts "third param specifies num features/compounds that are printed\n\n"
  abort
end

d = ARGV[0]
transposed = (ARGV[1]=~/features/)
num_print = ARGV[2].to_i

file_feat = "data/05/#{d}_new-features.csv"
file_orig = "data/02/#{d}_orig-features.csv"
puts "comparing #{file_feat} and #{file_orig}"

@inchis = []

feat = []
CSV.foreach(file_feat) do |row|
  feat << row
end

orig = []
#  CSV.foreach("data/#{d}_orig-features-quotes.csv") do |row|
CSV.foreach(file_orig) do |row|
#CSV.foreach("data/#{d}_noarom-features.csv") do |row|
  orig << row
end

match = 0
total = 0
orig_nil = 0
new_nil = 0
orig_0 = 0
new_0 = 0
diff = 0
epsilon_ratio = 0.1

dev = []

raise if feat.size!=orig.size
(0..feat.size-1).each do |r|
  
  dev << feat[r] if (r==0)
  
  raise "num columns in row #{r} differ, #{feat[r].size} != #{orig[r].size}" if feat[r].size!=orig[r].size
  raise "inchis differ #{feat[r][0]} != #{orig[r][0]}" if feat[r][0]!=orig[r][0]
  if r>0
    dev_per_compound = [feat[r][0]]
    (1..feat[r].size-1).each do |c|
      total += 1
      f_missing = feat[r][c]==nil || feat[r][c].to_s.size==0
      o_missing = orig[r][c]==nil || orig[r][c].to_s.size==0
      if (f_missing != o_missing)
        #         $stderr.puts "one value for #{feat[0][c]}/#{orig[0][c]} is missing, new features: #{feat[r][c]} != orig features: #{orig[r][c]}, inchi: #{orig[r][0]}"
        if f_missing
          dev_ratio = 10
          new_nil+=1
        else
          dev_ratio = 20
          orig_nil+=1
        end
      else 
        f = feat[r][c].to_f
        o = orig[r][c].to_f
        if ((f==0.0 and o!=0.0) or (f!=0.0 and o==0.0))
          if (f==0.0 and o!=0.0)
            dev_ratio = 11
            new_0+=1
          else
            dev_ratio = 21
            orig_0+=1
          end
        else
          dev_ratio = 1 - [f.abs,o.abs].min/[f.abs,o.abs].max
          if (f!=o && dev_ratio > epsilon_ratio)
            #            $stderr.puts "deviation to high for #{feat[0][c]}/#{orig[0][c]}, new features: #{feat[r][c]} != orig features: #{orig[r][c]}, inchi: #{orig[r][0]}, deviation #{dev_ratio}"
            diff += 1
          else
            dev_ratio = 0
            match += 1
          end
        end
      end
      dev_per_compound << dev_ratio
    end
    #      puts dev_per_compound.inspect
    dev << dev_per_compound
  end
end

puts "matching values #{match}/#{total} #{(match/total.to_f*100.0).round}%"
puts "no matches:"
puts "#{orig_nil} orig-nil"
puts "#{new_nil} new-nil"
puts "#{orig_0} orig-0"
puts "#{new_0} new-0"
puts "#{diff} delta > #{epsilon_ratio*100}%"
puts ""

class Array
  def max1_sum
    inject(0.0) { |result, el| result + [1,el].min }
  end
  
  def abs_mean 
    max1_sum / size
  end
end

dev = dev.transpose if transposed

puts ""
dev.shift
dev.sort!{ |b,a| a[1..-1].abs_mean <=> b[1..-1].abs_mean }
puts "top #{num_print} diffing #{transposed ? "features" : "compounds"} (numbers is diff between values in percent): "
num_print.times do |i|
  d =  dev[i].collect do |x|
    unless x.is_a?(Numeric)
      x
    else
      if x==20
        "orig-nil"
      elsif x==10
        "new-nil"
      elsif x==21
        "orig-0"
      elsif x==11
        "new-0"
      else
        (x*100).round
      end
    end
  end
  puts d.inspect
end




