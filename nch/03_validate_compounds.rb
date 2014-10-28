#!/usr/bin/env ruby

require "csv"
require "uri"

require "./config.rb"

DATA.each do |d|
  puts "\ndataset name #{d}"

  next if d=="LOAEL-mg"

  @inchis = []

  all_compounds = (d=="LOAEL-mol" ? "endpoint" : "complete")    
  [all_compounds,"orig-features"].each do |mode|

    csv_string = CSV.generate({:force_quotes=>true}) do |csv|
      first = true
      CSV.foreach("data/02/#{d}_#{mode}.csv") do |row|
        if (first)
          first = false
        else
          inchi = URI.unescape(row[0])
          if mode==all_compounds
            @inchis << inchi
          else
            raise "features-set inchi not found in complete-set #{inchi}" unless @inchis.first==inchi
            @inchis.delete(inchi)
          end
        end
      end
    end
    if mode==all_compounds
      puts @inchis.size.to_s+" compounds in complete-set"
      @inchis.uniq!
      File.open("data/03/#{d}_uniq.csv","w").puts "\""+(["InChI"]+@inchis).join("\"\n\"")+"\""
      puts @inchis.size.to_s+" uniq compounds in complete-set (written to data/03/#{d}_uniq.csv)"
    else
      raise "complete-set inchis not found in orig-features-set #{@inchis.inspect}" unless @inchis.size==0
      puts "inchis in orig-features-set uniq and all included in complete-set"
    end

  end

  puts ""

end

