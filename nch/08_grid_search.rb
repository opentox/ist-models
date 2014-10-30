#!/usr/bin/env ruby

require "./config.rb"

require "bundler"
Bundler.require

DATA.each do |d|
  puts ""
  puts d

  dataset_uri = dataset_uri(d)
  prediction_feature = prediction_feature(d)

  results = []
#  skip_ratio = 0.8
#  random_seed = 3
  {
    all_feature_dataset_uri(d)=>"all-pc-features",
#    new_feature_dataset_uri(d)=>"new-pc-features",
#    ob_feature_dataset_uri(d)=>"ob-pc-features",
  }.each do |feature_dataset_uri,f_desc|
    [ 0.65 ].each do |min_sim| # [0.2,0.4,0.6,0.8]
      [ 0.0 ].each do |min_train| #[0.0,0.1,0.2]

        puts "\nfeatures #{f_desc}"
        puts "min_sim #{min_sim}"
        puts "min_train #{min_train}"
        
        params = { :dataset_uri => dataset_uri,
          :algorithm_uri => File.join($algorithm[:uri],"lazar"),
          :algorithm_params => "feature_dataset_uri=#{feature_dataset_uri};min_sim=#{min_sim};min_train_performance=#{min_train}",
          :prediction_feature => prediction_feature,
          :loo => "uniq", }
        if defined?(skip_ratio)
          params[:skip_ratio] = skip_ratio
          params[:random_seed] = random_seed
        end
        cv_uri = wait_for_task(OpenTox::RestClientWrapper.post("http://localhost:8087/validation/crossvalidation/loo",params))
        cv = OpenTox::Crossvalidation.find(cv_uri)
        puts "Cross-Validation: "+cv.uri
        r_square = cv.statistics.metadata[RDF::OT.regressionStatistics.to_s][RDF::OT.rSquare.to_s]
        unpredicted = cv.statistics.metadata[RDF::OT.numUnpredicted.to_s]
        puts "r^2 #{r_square}"
        #      r = OpenTox::CrossvalidationReport.create(cv.uri)
        #      puts "Report: "+r.uri
        
        results << {:min_sim => min_sim, :min_train=>min_train, :cv => cv_uri, :r_square => r_square, :unpredicted => unpredicted, :features => f_desc}#, :report => r.uri}
        puts results.to_yaml
      end
    end
  end
end
