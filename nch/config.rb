
#DATA = ["LOAEL-mol", "LOAEL-mg","MOU"]
DATA = ["MOU"]

URIS = {
  "LOAEL-mol"=>{
  #  :dataset_uri=>"http://localhost:8083/dataset/3da90c55-0388-42a0-8ada-978abe4a515c",
  #  :prediction_feature=>"http://localhost:8084/feature/2a74d78d-5b3d-438c-a1e5-6cfb16bd9354",
  #  :new_feature_dataset_uri=>"http://localhost:8083/dataset/7de04de4-41ce-4528-97c2-fd92fbb4d0b8",
  #  :orig_feature_dataset_uri=>"http://localhost:8083/dataset/e9016641-dddb-434f-bb05-63d80a37679a",
  }, 
  "LOAEL-mg"=>{
  #  :dataset_uri=>"http://localhost:8083/dataset/4f3b9de4-0494-4339-8ebd-e6c6c1984a23",
  #  :prediction_feature=>"http://localhost:8084/feature/ba5b0f78-36bc-4ac3-8020-9d8b2ca3bd13",
  #  :new_feature_dataset_uri=>"http://localhost:8083/dataset/7de04de4-41ce-4528-97c2-fd92fbb4d0b8",
  #  :orig_feature_dataset_uri=>"http://localhost:8083/dataset/e9016641-dddb-434f-bb05-63d80a37679a",
  }, 
  "MOU"=>{    
  #  :dataset_uri=>"http://localhost:8083/dataset/f0af478a-51e6-41a5-adb2-d1a9bedf8981",
  #  :prediction_feature=>"http://localhost:8084/feature/432f18c5-ff8f-4ff2-a1cc-cbda1c43cff9",
  #  :test_dataset_uri=>"http://localhost:8083/dataset/a5c39a5d-8747-495a-8d30-6ee9abdd5f3b",
  #  :new_feature_dataset_uri=>"http://localhost:8083/dataset/8d324c7d-e6fe-4807-b2f8-e851750b959d",
  #  :orig_feature_dataset_uri=>"http://localhost:8083/dataset/cc651943-886c-4290-b346-41d1c951476a",
  },
}

def info(d)
  puts d.uri
  if d.is_a?(OpenTox::Dataset)
    puts "#{d.compounds.size} compounds"
    puts "#{d.features.size} features"
#    puts d.features.collect{|f| "#{f.title} : #{f[RDF::type]}"}.inspect
  end
end

def plz_add(msg)
  $stderr.puts "please add to config.rb: #{msg}"
  abort
end

def dataset_uri(d)
  if URIS[d] and URIS[d][:dataset_uri]
     URIS[d][:dataset_uri]
  else
    dataset = OpenTox::Dataset.new	
    dataset.upload File.join("data/02/#{d}_endpoint.csv")
    info(dataset)
    plz_add "dataset_uri #{dataset.uri} and prediction_feature #{dataset.features.first.uri}"
  end
end

def prediction_feature(d)
  if URIS[d] and URIS[d][:prediction_feature]
     URIS[d][:prediction_feature]
  else
    plz_add "prediction_feature by uploading dataset"
  end
end

def test_dataset_uri(d)
  if URIS[d] and URIS[d][:test_dataset_uri]
     URIS[d][:test_dataset_uri]
  else 
    pred_feat = prediction_feature(d)
    dataset = OpenTox::Dataset.new	
    dataset.upload File.join("data/#{d}_test.csv")
    info(dataset)
    raise "uri of test dataset feature != prediction_feature" unless dataset.features.first.uri==pred_feat
    plz_add "test_datsaet_uri #{dataset.uri}"
  end
end

def new_feature_dataset_uri(d)
  if URIS[d] and URIS[d][:new_feature_dataset_uri]
     URIS[d][:new_feature_dataset_uri]
  else 
    u_dataset = OpenTox::Dataset.new 
    u_dataset.upload File.join("data/03/#{d}_uniq.csv")
    puts "Unique Dataset: "+u_dataset.uri
    info(u_dataset)
    feature_names =  File.open("data/04/#{d}.feature_names","r").read.chomp.split(",")
    puts "Features: "+feature_names.inspect
    new_feat_uri = wait_for_task(OpenTox::RestClientWrapper.post("http://localhost:8081/algorithm/descriptor/physchem",{:dataset_uri => u_dataset.uri, :descriptors => feature_names}))
    f_dataset = OpenTox::Dataset.new new_feat_uri
    info(f_dataset)
    plz_add "feature_dataset_uri #{new_feat_uri}"
  end
end

def orig_feature_dataset_uri(d)
  if URIS[d] and URIS[d][:orig_feature_dataset_uri]
     URIS[d][:orig_feature_dataset_uri]
  else
    f = OpenTox::Dataset.new
    f.upload File.join("data/02/#{d}_orig-features.csv")
    info(f)
    plz_add "orig_feature_dataset_uri #{f.uri}"
  end
end



