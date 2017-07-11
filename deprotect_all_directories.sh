#! /bin/bash
#
# This assumes you have your Qiqqa database tree located at
#    ./base/
# (relative to this script!)
#
# This assumes you have your Qiqqa PDF dump/monitor collection directory tree located at
#    ../Sopkonijn/\!QIQQA-pdf-watch-dir/
# (relative to this script!)
#

# as per https://stackoverflow.com/questions/9772036/pass-all-variables-from-one-shellscript-to-another#answer-28490273
set -a

# as per https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
#TOOLDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# ^--- does not work!
TOOLDIR=/d/Qiqqa
echo "Tools directory: $TOOLDIR"

# qpdf binaries are located in this directory:
QPDFDIR=$TOOLDIR/qpdf-6.0.0/bin
if ! test -f $QPDFDIR/qpdf.exe ; then
    echo "### ERROR: TOOLDIR or QPDFDIR not set correctly or QPDF binary not installed in the expected spot. Aborting."
    exit 1
fi

QIQQA_MONITOR_DIR=/w/Sopkonijn/\!QIQQA-pdf-watch-dir
QIQQA_BUFFER_DIR=/w/Sopkonijn/\!QIQQA-pdf-buffer-dir
QIQQA_DB_BASE_DIR="$( realpath $TOOLDIR/base/Guest )"
QIQQA_DOCUMENTS_DIR="$( realpath $QIQQA_DB_BASE_DIR/documents )"

if ! test -d "$QIQQA_DOCUMENTS_DIR" ; then
    if ! test -d "$QIQQA_DB_BASE_DIR" ; then
        echo "### ERROR: we're not pointing at the documents store of QIQQA itself. Correct the script. Aborting."
        exit 1
    else
        mkdir -p "$QIQQA_DOCUMENTS_DIR"
        if ! test -d "$QIQQA_DOCUMENTS_DIR" ; then
            echo "### ERROR: we're not able to create the documents store of QIQQA itself. Correct the script. Aborting."
            exit 1
        fi
    fi
fi

if ! test -d "$QIQQA_MONITOR_DIR" ; then
    echo "### ERROR: The path to the directory tree which is monitored by QIQQA for new PDFs is ill configured. Correct the script. Aborting."
    exit 1
fi

if ! test -d "$QIQQA_BUFFER_DIR" ; then
    echo "### ERROR: The path to the MONITOR BUFFER directory tree which is used to dump and prep PDFs before sending them to the monitor directory is ill configured. Correct the script. Aborting."
    exit 1
fi

set +a



#
# NOTE: wait with deprotecting / decrypting PDFs until Qiqqa has turned the originals into hash-named ones so we can
# easily link up originals to deprotected copies!
#
#
# for f in $( find "$QIQQA_MONITOR_DIR" -mindepth 1 -maxdepth 1 -type d ! -name __prot ) ; do
#     echo "Processing directory: $f"
#     cd "$f"
#     $TOOLDIR/mv_protected_pdf.sh
# done


# also check the Qiqqa store itself!
#cd ~/AppData/Local/Quantisle/Qiqqa/Guest/documents
cd $QIQQA_DOCUMENTS_DIR

echo "Processing QIQQA Store itself: $(pwd)"
$TOOLDIR/mv_protected_pdf.sh



