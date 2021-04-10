#!/bin/bash

USER=rki

PASS=rki

find .  -name "*.csv" | while read file;
do
    echo "################## Import $file ####################"
    header="$(head -n 1 $file)"
    echo "++++++++++ Header $header ++++++++++++++++++++++"
mysql -u "$USER" -p"$PASS" --execute="LOAD DATA LOCAL INFILE '$file' INTO TABLE rki.covid19 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES ($header); SHOW WARNINGS"
done

