#! /bin/bash
#
# macro to copy all unreadable PDFs already processed by QiQQA and copied into the __store/ directory into a directory 
# where we can watch them easily using an OCR program, e.g. ReadIRIS.
# 
# To prevent us from redoing the work on a re-run, we note every PDF we processed in a separate file.
#


if ! test -f "$XPDFDIR/pdftotext.exe" ; then
    echo "### ERROR: XPDFDIR not set correctly or PDFTOTEXT binary not installed in the expected spot. Aborting."
    exit 1
fi

if test -n "$1" && test -d "$1" ; then
    QIQQA_BUFFER_DIR="$( realpath $1 )"
fi

if ! test -d "$QIQQA_BUFFER_DIR" ; then
    echo "### ERROR: The path to the MONITOR BUFFER directory tree which is used to dump and prep PDFs before sending them to the monitor directory is ill configured. Correct the script. Aborting."
    exit 1
fi





pushd .                                                                                                     2> /dev/null  > /dev/null




shopt -s globstar

# copy all processed PDFs to target directory to become one big collective:
mkdir -p "$QIQQA_BUFFER_DIR/__nontext"                                                                      2> /dev/null  > /dev/null
mkdir -p "$QIQQA_BUFFER_DIR/__store"                                                                        2> /dev/null  > /dev/null
cd "$QIQQA_BUFFER_DIR/__store"
for f in $( find . -type f -name '*.pdf' ) ; do
    # turn path into a unique filename so we can process both protected and unprotected PDFs, etc.:
    set g=$( echo $f | sed -e 's/[.]\\\//_/g' )
    echo "Copying PDF file $f to ./__nontext/$g..."
    if grep "$f" "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt" ; then
        # skip this one, we've already processed it!
    else
        # check if the PDF produces sufficient readable text:
        if test $( "$XPDFDIR/pdftotext.exe" -nodiag -simple "$f" - | \
             sed -e 's/[^a-z]/ /ig' \
                 -e 's/\b[a-z]\{1,3\}\b/ /ig' \
                 -e 's/\s\+/ /g'    | \
             wc -w ) -gt 500 ; then
            # we've got plenty words (larger than 3 characters each) coming out of that one!
            #
            # hence we don't need to feed this one to the OCR app!
            echo "TEXT-OK: $f" >> "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt"
        else
            # DO NOT reprocess already queued / processed PDFs which turn out to have too little content
            # to make the benchmark/heuristic here anyhow:
            if $( echo "$f" | grep "__nontext" ) ; then
                echo "TOO-LITTLE-CONTENT: $f" >> "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt"
            else
                cp -n -- "$f" "$QIQQA_BUFFER_DIR/__nontext/$g"
                if test -f "$QIQQA_BUFFER_DIR/__nontext/$g" ; then
                    echo "OCR: $f" >> "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt"
                    echo "OCR: $g" >> "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt"
                fi
            fi
        fi
    fi
done
rmdir "$QIQQA_BUFFER_DIR/__store"                                                                           2> /dev/null  > /dev/null
rmdir "$QIQQA_BUFFER_DIR/__nontext"                                                                         2> /dev/null  > /dev/null

# now go and OCR those PDF files which have not been OCRed yet:
if test -d "$QIQQA_BUFFER_DIR/__nontext" ; then
    cd "$QIQQA_BUFFER_DIR/__nontext"
    echo "Going to OCR all not-yet-decrypted files..."
    for f in *.pdf ; do
        if test -f "$f" && ! test -f "__decrypted/$f" ; then
            echo "Decrypting $f..."
        fi
    done

    cd ..
    # remove directories when they're empty, i.e. when there weren't any crypted PDFs to treat:

    rmdir __store/__decrypted                                                                               2> /dev/null  > /dev/null
    rmdir __store                                                                                           2> /dev/null  > /dev/null
fi


popd                                                                                                        2> /dev/null  > /dev/null

