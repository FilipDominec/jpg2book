#!/bin/bash

## Handle filenames containing space, too
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

mv all.html all.html.bkup -f
for INPUT in `ls *jpg *png *tif`; do
	TEMP1=`mktemp`.png 
	date
	if [ ! -f "nowhiteboard" ] ; then
		echo "	bin/whiteboard -e both -f 12 -o 5 -s 1 -t 30 $INPUT $TEMP1"
		nice whiteboard -e both -f 12 -o 5 -s 1 -t 30 "$INPUT" $TEMP1
	fi
	if [ -f "nowhiteboard" ] ; then
		cp "$INPUT" $TEMP1
	fi

	TEMP2=`mktemp`.png 

	if [ ! -f "nothres" ] ; then
		echo "	convert $TEMP1 -threshold 70% $TEMP2"
		convert $TEMP1 -threshold 70% $TEMP2
	fi
	if [ -f "nothres" ] ; then
		cp $TEMP1 $TEMP2
	fi

	TEMP3=`mktemp`.html 
	echo "	cuneiform -l cze -f html -o $TEMP3 $TEMP2"
	nice cuneiform -l cze -f html -o $TEMP3 $TEMP2 | sed -e '/Cuneiform/d'

	if [ ! -f "$TEMP3" ] ; then
		convert $TEMP1 -threshold 70% -resize 80% $TEMP2
		nice cuneiform -l cze -f html -o $TEMP3 $TEMP2
	fi
	if [ ! -f "$TEMP3" ] ; then
		convert $TEMP1 -threshold 70% -resize 60% $TEMP2
		nice cuneiform -l cze -f html -o $TEMP3 $TEMP2
	fi

	sed -i $TEMP3  -e 's/<body>/\n<body>\n/'
	sed -i $TEMP3  -e 's/<\/p>\s*<p/<\/p>\n<p/g'
	sed -i $TEMP3  -e 's/<\/body>/\n<\/body>\n/'

	cat $TEMP3 >> all.html
	rm $TEMP1 $TEMP2 $TEMP3 
	echo "<!-- (((EndPage))) -->" >> all.html
	echo "<!-- End of page: $INPUT -->" >> all.html
	echo "<!-- (((StartPage))) -->" >> all.html 
done
echo "</body></html>" >> all.html 
cp all.html all.preprocessed.html

	
sed -i all.html	-e '/<\/body>/,/(((EndPage)))/ d'
sed -i all.html	-e '/(((StartPage)))/,/<body>/ d'
sed -i all.html -e 's/-\s*\n//g' -e 's/<.span>\s*$//g'
sed -i all.html -e :a -e '/-\s*$/N; s/-\s*\n//; ta'
sed -i all.html -e 's/<p><\/p>//'
sed -i all.html -e 's/\n<\/p>/<\/p>/'
sed -i all.html -e 's/\n<\/p>/<\/p>/'
sed -i all.html -e 's/â€”/-/'

IFS=$SAVEIFS

