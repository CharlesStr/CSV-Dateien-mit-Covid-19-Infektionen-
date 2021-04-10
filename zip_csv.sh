#!/bin/bash

find . -name "*.csv" ! -path "./Maerz/*" ! -path "./April/*" ! -path "./Mai/*" ! -path "./Juni/*" ! -path "./July/*" ! -path "./August/*" ! -iname 'RKI_COVID19_2020-09-0*' ! -name RKI_COVID19_2020-09-10.csv ! -name RKI_COVID19_2020-09-11.csv ! -name RKI_COVID19_2020-09-12.csv ! -name RKI_COVID19_2020-09-13.csv ! -name RKI_COVID19_2020-09-14.csv ! -name RKI_COVID19_2020-09-15.csv ! -name RKI_COVID19_2020-09-16.csv | while read filename; do zip -r "${filename%.*}.zip" "$filename"; done;
