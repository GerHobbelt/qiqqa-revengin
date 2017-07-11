#! /bin/bash
#
# macro to find protected PDFs in the given directory TREE and move them into the newly created __prot subdirectory
#
# https://stackoverflow.com/questions/35594240/how-to-check-if-pdf-is-password-protected-using-static-tools#
#


if ! test -f $QPDFDIR/qpdf.exe ; then
    echo "### ERROR: QPDFDIR not set correctly or QPDF binary not installed in the expected spot. Aborting."
    exit 1
fi

if ! test -d "$QIQQA_BUFFER_DIR" ; then
    echo "### ERROR: The path to the MONITOR BUFFER directory tree which is used to dump and prep PDFs before sending them to the monitor directory is ill configured. Correct the script. Aborting."
    exit 1
fi



pushd .                                                                                                     2> /dev/null  > /dev/null




shopt -s globstar

mkdir -p "$QIQQA_BUFFER_DIR/__prot/__decrypted"                                                             2> /dev/null  > /dev/null
grep -e '\/Encrypt' -l -- **/*.pdf | xargs --replace=XXX  cp -n -- XXX "$QIQQA_BUFFER_DIR/__prot/"
rmdir "$QIQQA_BUFFER_DIR/__prot"                                                                            2> /dev/null  > /dev/null

# now go and decrypt those PDF files which have not been decrypted yet:
if test -d "$QIQQA_BUFFER_DIR/__prot" ; then
    cd "$QIQQA_BUFFER_DIR/__prot"
    echo "Going to decrypt all not-yet-decrypted files..."
    for f in *.pdf ; do
        if test -f "$f" && ! test -f "__decrypted/$f" ; then
            echo "Decrypting $f..."
            $QPDFDIR/qpdf --decrypt "$f" "__decrypted/$f"
        fi
    done

    cd ..
    # remove directories when they're empty, i.e. when there weren't any crypted PDFs to treat:

    rmdir __prot/__decrypted                                                                                2> /dev/null  > /dev/null
    rmdir __prot                                                                                            2> /dev/null  > /dev/null
fi


popd                                                                                                        2> /dev/null  > /dev/null

