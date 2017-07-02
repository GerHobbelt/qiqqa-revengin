#! /bin/bash
#

pushd .
if [ -d "$1" ] ; then
	cd $1
fi
echo 'Working directory: ' $( pwd )

for f in $( find . -mindepth 1 -maxdepth 1 -type d ! -name __prot ) ; do 
	echo "Processing directory: $f" 
	pushd "$f"               															2> /dev/null  > /dev/null 
	~/mv_protected_pdf.sh
	popd               																		2> /dev/null  > /dev/null 
done


# also check the Qiqqa store itself!
cd ~/AppData/Local/Quantisle/Qiqqa/Guest/documents
echo "Processing QIQQA Store itself: $(pwd)" 
~/mv_protected_pdf.sh

popd

