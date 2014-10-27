#!/usr/bin/env ruby

require "csv"
require "uri"

require "./config.rb"

DATA.each do |d|
  $stderr.puts "\ndataset name #{d}"

  @inchis = []
  
  ["orig-features","endpoint","complete","test"].each do |mode|

    next unless File.exist?("data/01/#{d}_#{mode}_enc.csv")

#    csv_string = CSV.generate({:force_quotes=>true}) do |csv|
    csv_string = CSV.generate() do |csv|

      first = true
      skip_lipinksi = false
      CSV.foreach("data/01/#{d}_#{mode}_enc.csv") do |row|
        if (first)
          first = false
          if row[-1]=="LipinksiFailures"
            $stderr.puts "Skipping col LipinksiFailures from #{mode}"
            skip_lipinksi=true
          end
          if row[-1]=="LOAEL_log_mmol_kg_bw_day"
            $stderr.puts "rename mmol to mol (LOAEL_log_mmol_kg_bw_day to LOAEL_log_mol_kg_bw_day)"
            row[-1] = "LOAEL_log_mol_kg_bw_day"
          end
          raise row.inspect unless row[0]=="SMILES"
          csv << ["InChI"]+row[1..(skip_lipinksi ? -2 : -1)]
        else
          inchi = URI.unescape(row[0])
          csv << [inchi]+row[1..(skip_lipinksi ? -2 : -1)]
        end
      end
    end

    header = csv_string.split("\n")[0]
    content = csv_string.split("\n")[1..-1]
    content.sort!
    csv_string = header+"\n"+content.join("\n")

#    dest = (mode=="features" ? "orig-features-quotes" : mode)
#    dest = (mode=="features" ? "orig-features" : mode)
    File.open("data/02/#{d}_#{mode}.csv","w").puts csv_string
    $stderr.puts "written to data/02/#{d}_#{mode}.csv"
  end

end

