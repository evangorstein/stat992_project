#!\bin\bash
 
# this script downloads all quality_variant files from the 1001 genome project. The files selected are those
# listed at http://signal.salk.edu/atg1001/download.php. Files are downloaded from 
# http://signal.salk.edu/atg1001/data/Salk/quality_variant_[FILENAME].txt and stored in the 
# data/ directory named [FILENAME].txt, with the filename taken from the salk website.

# if our data directory isn't created, make it
if [ ! -d 'data/' ]
then
    mkdir data
fi

# if we have a log file remove it, we'll need it fresh
if [ -f 'data/log.txt' ]
then 
    rm data/log.txt
fi

# download the list of files from the salk website, extract the filenames
dnld=`curl -s http://signal.salk.edu/atg1001/download.php`

# to preview this script with fewer files, comment out this line
flnms=`echo -e $dnld | sed -nE 's/.*accession\.php\?id=[A-Za-z0-9_]+>([A-Za-z0-9_]+)<.*/\1/pg'`

# and uncomment this line
# flnms=`echo -e $dnld | sed -nE 's/.*accession\.php\?id=[A-Za-z0-9]+>([A-Za-z0-9_]+)<.*/\1/pg'`

cd data

# variables required for printing progress
numfls=`echo $flnms | wc -l | sed -E 's/ //g'`
count=1
tothash=20

# loop over the filenames
echo $flnms | while read flnm
do  
    # print our progress to stdout
    numhash=$(( $count * $tothash / $numfls ))
    space=`printf ' %.0s' {1..$(( $tothash - $numhash ))}`
    hash=`printf '#%.0s' {0..$numhash}`
    printf "downloading file "$count" of "$numfls"  |"$hash$space"|"'\r'
    count=$(( $count + 1 ))

    # print the file name to the logfile so we know what file each line is referring to
    echo $flnm >> "log.txt"
    # download the actual files from the salk website
    # TODO: rewrite to use one curl request for all the files?
    curl "http://signal.salk.edu/atg1001/data/Salk/quality_variant_"$flnm".txt" -O 2>> "log.txt"

    # make sure this file was downloaded correctly
    if [ ! -f "quality_variant_"$flnm".txt" ] || [ `wc -l "quality_variant_"$flnm".txt" | sed -E 's/ //g'` = 0 ] \
        || [ `head -n 1 "quality_variant_"$flnm".txt" | grep -q -E "xml.*encoding.*>"` ]
    then
        echo "\n"$flnm" not downloaded. See log.txt for details."
    fi 
done

# TODO: summary for downloads