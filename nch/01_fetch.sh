#!/bin/bash

cd data/01

rm *LOAEL*mol*
wget https://raw.githubusercontent.com/opentox/test/TD50/LOAEL/LOAEL_mol.csv
mv LOAEL_mol.csv LOAEL-mol_endpoint_enc.csv

wget https://raw.githubusercontent.com/opentox/test/TD50/LOAEL/LOAEL_topological_mg_mol.csv
mv LOAEL_topological_mg_mol.csv LOAEL-mol_orig-features_enc.csv
echo "" >> LOAEL-mol_orig-features_enc.csv

rm *LOAEL*mg*
wget https://raw.githubusercontent.com/opentox/test/TD50/LOAEL/LOAEL_mg.csv
mv LOAEL_mg.csv LOAEL-mg_endpoint_enc.csv

rm *MOU*
wget https://raw.githubusercontent.com/opentox/test/TD50/TD50/MOU_training.csv
mv MOU_training.csv MOU_endpoint_enc.csv
wget https://raw.githubusercontent.com/opentox/test/TD50/TD50/MOU_test.csv
mv MOU_test.csv MOU_test_enc.csv
echo "" >> MOU_test_enc.csv
cp MOU_endpoint_enc.csv MOU_complete_enc.csv
tail -n40 MOU_test_enc.csv >> MOU_complete_enc.csv

wget https://raw.githubusercontent.com/opentox/test/TD50/TD50/MOU_constitutional_06e4762c88_report.csv
mv MOU_constitutional_06e4762c88_report.csv MOU_orig-features_enc.csv
echo "" >> MOU_orig-features_enc.csv

cd -

