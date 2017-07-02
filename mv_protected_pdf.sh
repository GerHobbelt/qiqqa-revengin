#! /bin/bash
#
# macro to find protected PDFs in the given directory TREE and move them into the newly created __prot subdirectory
# 
# https://stackoverflow.com/questions/35594240/how-to-check-if-pdf-is-password-protected-using-static-tools#
#

pushd .
if [ -d "$1" ] ; then
	cd $1
fi
echo 'Working directory: ' $( pwd )

shopt -s globstar

mkdir -p __prot/__decrypted               																		2> /dev/null  > /dev/null 
grep -e '\/Encrypt' -l -- **/*.pdf  | grep -v -e '__prot/' | xargs --replace=XXX  mv -n XXX __prot/
rmdir __prot               																										2> /dev/null  > /dev/null

# now go and decrypt those PDF files which have not been decrypted yet:
if test -d __prot ; then
	cd __prot
	echo "Going to decrypt all not-yet-decrypted files..."
	for f in *.pdf ; do
		if test -f "$f" && ! test -f "__decrypted/$f" ; then
			echo "Decrypting $f..."
		  qpdf --decrypt  "$f" "__decrypted/$f"
		fi
	done

	cd ..
	# remove directories when they're empty, i.e. when there weren't any crypted PDFs to treat:
  rmdir __prot/__decrypted               																		2> /dev/null  > /dev/null 
  rmdir __prot                          																		2> /dev/null  > /dev/null 

fi


popd

