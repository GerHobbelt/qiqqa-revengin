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

if ! test -d "$QIQQA_MONITOR_DIR" ; then
    echo "### ERROR: The path to the directory tree which is monitored by QIQQA for new PDFs is ill configured. Correct the script. Aborting."
    exit 1
fi

if ! test -d "$READIRIS_WATCH_DIR" ; then
    echo "### ERROR: The path to the READIRIS WATCH directory which is used to dump PDFs for ReadIRIS to process is ill configured. Correct the script. Aborting."
    exit 1
fi

if ! test -d "$READIRIS_OUTPUT_DIR" ; then
    echo "### ERROR: The path to the READIRIS OUTPUT directory which is used by ReadIRIS to dump the OCR'ed PDFs is ill configured. Correct the script. Aborting."
    exit 1
fi





pushd .                                                                                                     2> /dev/null  > /dev/null




shopt -s globstar

# copy all processed PDFs to target directory to become one big collective:
mkdir -p "$QIQQA_BUFFER_DIR/__nontext"                                                                      2> /dev/null  > /dev/null
mkdir -p "$QIQQA_BUFFER_DIR/__store/__decrypted"                                                            2> /dev/null  > /dev/null
# all PDFs are also in the __decrypted directory, unless they are faulty.
# Hence we obtain our list from the decrypted directory so as not to feed
# illegal/corrupted PDFs to the OCR application:
cd "$QIQQA_BUFFER_DIR/__store/__decrypted"
if ! test -f "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt" ; then
    echo "-------------------------------------------------------" > "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt"
fi
for f in $( find . -type f -name '*.pdf' ) ; do
    # turn path into a unique filename so we can process both protected and unprotected PDFs, etc.:
    set g=$( echo $f | sed -e 's/[.]\\\//_/g' )

    if grep "$f" "$QIQQA_BUFFER_DIR/__nontext_detected_list.txt" ; then
        # skip this one, we've already processed it!
        echo "."
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
                echo "Copying PDF file $f to ./__nontext/$g..."
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
        bn=$(basename -s .pdf $f);
        # skip this one when we already know ReadIRIS will crash processing this one:
        if test -d "../__ReadIRIS_crashes_on_these" ; then
            # see also: https://stackoverflow.com/questions/3294072/bash-get-last-dirname-filename-in-a-file-path-argument
            # and:      http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
            # and:      https://unix.stackexchange.com/questions/203043/count-files-in-directory-with-specific-string-on-name
            cache_files=(../__ReadIRIS_crashes_on_these/$bn*.pdf)
            if test -f "${cache_files[0]}" ; then
                # skip this one, we've already processed it!
                echo ".CRASH"
                continue
            fi
        fi
        # skip this one when we already know ReadIRIS will produce a (near-)empty PDF for this one:
        if test -d "../__ReadIRIS_produces_empty_file" ; then
            cache_files=(../__ReadIRIS_produces_empty_file/$bn*.pdf)
            if test -f "${cache_files[0]}" ; then
                # skip this one, we've already processed it!
                echo ".EMPTY"
                continue
            fi
        fi
        # skip this one when the OCR'ed result is already available in the Qiqqa watch directory:
        if test -d "$QIQQA_MONITOR_DIR/__OCR_done__" ; then
            cache_files=($QIQQA_MONITOR_DIR/__OCR_done__/$bn*.pdf)
            if test -f "${cache_files[0]}" ; then
                # skip this one, we've already processed it!
                # echo ".DONE"
                continue
            fi
        fi
        # skip this one when the OCR'ed result is already available in the ReadIRIS output directory:
        if test -d "$READIRIS_OUTPUT_DIR" ; then
            # see also: https://stackoverflow.com/questions/3294072/bash-get-last-dirname-filename-in-a-file-path-argument
            cache_files=($READIRIS_OUTPUT_DIR/$bn*.pdf)
            if test -f "${cache_files[0]}" ; then
                # skip this one, we've already processed it!
                echo ".READIRIS_DONE"
                continue
            fi
        fi
        # no need to check destination: we don't overwrite with `cp -n`,
        # yet still we check so as not to yak about every file that's already 
        # waiting in there anyway.
        if ! test -f "$READIRIS_WATCH_DIR/$f" ; then
            cp -n -- "$f" "$READIRIS_WATCH_DIR/$f"
            echo ".ADDED: $f"
        fi
    done
fi


popd                                                                                                        2> /dev/null  > /dev/null

