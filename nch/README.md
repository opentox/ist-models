

scripts
-------------------------------------
* results are stored in the data folder in the corresponding sub-folders: 01, 02, ...
* config.rb defines which datasets to employ and stores URIs of already uploaded files

01_fetch - copies data from old repository and converts to a consistent naming scheme
02_decode_inchi.rb - decodes inchis and renames SMILES column to InChI
03_validate_compounds.rb - checks if all compounds are included in the feature set, stores uniq compounds without duplicates
04_get_feature_names.rb - extracts new features names for features from orig files
05_compute_features.rb - computes new features
06_compare_features.rb - compares orig features and new features
07_validate.rb - starts crossvalidation/test set validation with old / new features