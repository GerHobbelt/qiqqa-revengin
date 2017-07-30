#! /bin/bash
#
# macro to copy all PDFs already processed by QiQQA into a directory where we can reach them easily.
#


if ! test -f $QPDFDIR/qpdf.exe ; then
    echo "### ERROR: QPDFDIR not set correctly or QPDF binary not installed in the expected spot. Aborting."
    exit 1
fi

if ! test -d "$QIQQA_BUFFER_DIR" ; then
    echo "### ERROR: The path to the MONITOR BUFFER directory tree which is used to dump and prep PDFs before sending them to the monitor directory is ill configured. Correct the script. Aborting."
    exit 1
fi

if ! test -d "$QIQQA_DOCUMENTS_DIR" ; then
    echo "### ERROR: The path to the QIQQA DOCUMENTS directory tree which is used by QIQQA to store already processed PDFs is ill configured. Correct the script. Aborting."
    exit 1
fi




pushd .                                                                                                     2> /dev/null  > /dev/null




shopt -s globstar

# copy all processed PDFs to target directory to become one big collective:
mkdir -p "$QIQQA_BUFFER_DIR/__store/__decrypted"                                                            2> /dev/null  > /dev/null
for f in $( find . -type d ) ; do
    pushd .                                                                                                 2> /dev/null  > /dev/null
    echo "Copying Qiqqa storage directory $f..."
    cd "$f"
    cp -n -- *.pdf "$QIQQA_BUFFER_DIR/__store/"
    popd                                                                                                    2> /dev/null  > /dev/null
done
rmdir "$QIQQA_BUFFER_DIR/__store"                                                                           2> /dev/null  > /dev/null

# now go and decrypt those PDF files which have not been decrypted yet:
if test -d "$QIQQA_BUFFER_DIR/__store" ; then
    cd "$QIQQA_BUFFER_DIR/__store"
    echo "Going to decrypt all not-yet-decrypted files..."
    for f in *.pdf ; do
        if test -f "$f" && ! test -f "__decrypted/$f" ; then
            echo "Decrypting $f..."
            $QPDFDIR/qpdf --decrypt "$f" "__decrypted/$f"
        fi
    done

    cd ..
    # remove directories when they're empty, i.e. when there weren't any crypted PDFs to treat:

    rmdir __store/__decrypted                                                                               2> /dev/null  > /dev/null
    rmdir __store                                                                                           2> /dev/null  > /dev/null
fi


popd                                                                                                        2> /dev/null  > /dev/null

