#!/bin/bash

# Skript ohne Parameter wirkt auf alle CSV-Dateien(*.csv), sonst nur auf die CSV-Datei die als erster Parameter übergeben wird.
[ -z "$1" ] && files="*.csv" || files=$1

echo $files

# fix headers
find . -name "$files" -exec sed -i '1s#Meldedatum2#Meldedatum#g' {} \;  				# Meldedatum2 -> Meldedatum 
find . -name "$files" -exec sed -i '1s#Referenzdatum#Refdatum#g' {} \;  				# Referenzdatum -> Refdatum
find . -name "$files" -exec sed -i '1s#Refdatum2#Refdatum#g' {} \;                                  	# Refdatum2 -> Refdatum
find . -name "$files" -exec sed -i '1s#Landkreis ID#IdLandkreis#g' {} \;  				# Landkreis ID -> IdLandkreis
find . -name "$files" -exec sed -i '1s#Neuer Todesfall#NeuerTodesfall#g' {} \;  			# Neuer Todesfall -> NeuerTodesfall
find . -name "$files" -exec sed -i '1s#Neuer Fall#NeuerFall#g' {} \;  				# Neuer Fall -> NeuerFall
find . -name "$files" -exec sed -i '1s#Neu Genesen#NeuGenesen#g' {} \;  				# Neu Genesen -> NeuGenesen
find . -name "$files" -exec sed -i '1s#Anzahl Genesen#AnzahlGenesen#g' {} \;  			# Anzahl Genesen -> AnzahlGenesen
find . -name "$files" -exec sed -i '1s#Meldedatum2#Meldedatum#g' {} \;  				# Meldedatum2 -> Meldedatum
find . -name "$files" -exec sed -i '1s#ObjectId#FID#g' {} \; 					# ObjectID -> FID
find . -name "$files" -exec sed -i '1s#"##g'	{} \;							# " -> 

echo "header gefixt"

# fix data types

# einheitliches encoding ist utf-8 
find . -name "$files" | while read f 
do
  encoding=`file -i $f | cut -f 2 -d";" | cut -f 2 -d=`
  case $encoding in
    iso-8859-1)
    iconv -f iso8859-1 -t utf-8 $f > $f.utf8
    mv $f.utf8 $f
    ;;
  esac
done

echo "encoding gefixt"

# fix korrupte umlaute und scharfes s
find . -name "$files" -exec sed -i 's#├╝#ü#g' {} \; # ü z.b. Lübeck oder Neumünster
find . -name "$files" -exec sed -i 's#Ã¼#ü#g' {} \; # ü z.b. Fürth 
find . -name "$files" -exec sed -i 's#├ƒ#ß#g' {} \; # ß
find . -name "$files" -exec sed -i 's#ÃŸ#ß#g' {} \; # ß z.B. Spree-Neiße
find . -name "$files" -exec sed -i 's#├Â#ö#g' {} \; # ö
find . -name "$files" -exec sed -i 's#Ã¶#ö#g' {} \; # ö z.B. Tempelhof-Schöneberg
find . -name "$files" -exec sed -i 's#├ñ#ä#g' {} \; # ä 
find . -name "$files" -exec sed -i 's#Ã¤#ä#g' {} \; # ä

echo "korrupte umlaute gefixt"

# entferne byte order mark
find . -name "$files" -exec sed -i '1s/^\xEF\xBB\xBF//' {} \;

echo "bom entfernt"

# entferne carriage return
find . -name "$files" -exec sed -i 's/\r$//' {} \;

echo "carriage return entfernt"

#fix date types
find . -name "$files" -exec sed -i -E 's#([0-9]{2})\.([0-9]{2})\.([0-9]{4})#\3/\2/\1#g' {} \;
find . -name "$files" -exec sed -i -E 's# 00\:00\:00\+00##g' {} \;
find . -name "$files" -exec sed -i -E 's# 00\:00\:00##g' {} \;
find . -name "$files" -exec sed -i -E 's#([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})#\3/\2/\1#g' {} \;
find . -name "$files" -exec sed -i -E 's#([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})#\3/\2/\1#g' {} \;
find . -name "$files" -exec sed -i -E 's#([0-9]{4})\-([0-9]{1,2})\-([0-9]{1,2})#\1/\2/\3#g' {} \;
find . -name "$files" -exec sed -i -E 's#\.00##g' {} \;
# Datumswerte mit 0en auffüllen
find . -name "$files" -exec sed -i -E 's#([0-9]{4})\/([0-9]{1})\/([0-9]{1,2})#\1/0\2/\3#g' {} \;
find . -name "$files" -exec sed -i -E 's#([0-9]{4})\/([0-9]{2})\/([0-9]{1}),#\1/\2/0\3,#g' {} \; # komma ist noetig !

echo "datentypen korrigiert"

# suche dateien mit falschem datumsformat
echo "dateien haben ggf. falsches datumsformat. manuelle korrektur ist dann erforderlich. keine ausgabe bedeutet alles ist gut."
find . -name "$files" -exec grep -il "[0-9]\{4\}/[1,2,3][3-9]" {} \;

#sed -i -E 's#([0-9]{4})\/([0-9]{1,2})\/([0-9]{1,2})#\1/\3/\2#g' ./April/RKI_COVID19_2020-04-12.csv
#sed -i -E 's#([0-9]{4})\/([0-9]{1,2})\/([0-9]{1,2})#\1/\3/\2#g' ./April/RKI_COVID19_2020-04-17.csv
#sed -i -E 's#([0-9]{4})\/([0-9]{1,2})\/([0-9]{1,2})#\1/\3/\2#g' ./April/RKI_COVID19_2020-04-18.csv

# abschließende kontrolle datumsformat
echo "abschliessende kontrolle des datumsformats. keine ausgabe bedeutet alles ist gut."
find . -name "$files" ! -exec grep -q ',[0-9]\{4\}/[0-9]\{2\}/[0-9]\{2\},' {} \; -print

