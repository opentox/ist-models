#!/usr/bin/env ruby

require "./config.rb"

require "bundler"
Bundler.require

DATA.each do |d|
  puts ""
  puts d

  dataset_uri = dataset_uri(d)
  prediction_feature = prediction_feature(d)
  test_dataset_uri = test_dataset_uri(d) if d=="MOU"

  [ new_feature_dataset_uri(d), orig_feature_dataset_uri(d) ].each do |feature_dataset_uri|
    puts "\nvalidating with features #{feature_dataset_uri}"

    params = { :dataset_uri => dataset_uri,
      :algorithm_uri => File.join($algorithm[:uri],"lazar"),
      :algorithm_params => "feature_dataset_uri=#{feature_dataset_uri};min_sim=0.4;min_train_performance=0.1",
      :prediction_feature => prediction_feature}
    if (d=="LOAEL-mol" or d=="LOAEL-mg")
      params[:loo] = "uniq"
      cv_uri = wait_for_task(OpenTox::RestClientWrapper.post("http://localhost:8087/validation/crossvalidation/loo",params))
      cv = OpenTox::Crossvalidation.find(cv_uri)
      puts "Cross-Validation: "+cv.uri
      r = OpenTox::CrossvalidationReport.create(cv.uri)
      puts "Report: "+r.uri
    elsif (d=="MOU")
      params[:training_dataset_uri] = params.delete(:dataset_uri)
      params[:test_dataset_uri] = test_dataset_uri
      v = OpenTox::Validation.create_training_test_validation(params)
      puts "Validation: "+v.uri
      r = OpenTox::ValidationReport.create(v.uri)
      puts "Report: "+r.uri

#      cv_uri = wait_for_task(OpenTox::RestClientWrapper.post("http://localhost:8087/validation/crossvalidation",params))
#      cv = OpenTox::Crossvalidation.find(cv_uri)
#      puts "Cross-Validation: "+cv.uri
#      r = OpenTox::CrossvalidationReport.create(cv.uri)
#      puts "Report: "+r.uri
    else
      raise "add routine"
    end

#        :split_ratio => 0.925, # only required for training-test-split
#        :random_seed => 2}
#      v = OpenTox::Validation.create_training_test_split(p)
  end
end

