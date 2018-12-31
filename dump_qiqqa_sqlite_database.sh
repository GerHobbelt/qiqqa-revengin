#! /bin/bash
#
# script to brutally dump the entire QIQQA SQLITE database.
#
# The database dump will be dumped into the directory where this shell script resides...
# 

# as per https://stackoverflow.com/questions/9772036/pass-all-variables-from-one-shellscript-to-another#answer-28490273
set -a

# as per https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
#TOOLDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# ^--- does not work!
TOOLDIR=/d/Qiqqa
echo "Tools directory: $TOOLDIR"

# sqlite binaries are located in this directory:
SQLITEDIR=$TOOLDIR/sqlite3/
SQLITEBINARY=$SQLITEDIR/sqlite3.exe
if ! test -f $SQLITEBINARY ; then
    echo "### ERROR: TOOLDIR or SQLITEDIR not set correctly or SQLITE3 binary not installed in the expected spot. Aborting."
    exit 1
fi

QIQQA_TOP_BASE_DIR="$( realpath $TOOLDIR/base )"
QIQQA_DB_BASE_DIR="$( realpath $QIQQA_TOP_BASE_DIR/Guest )"
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

set +a








pushd .                                                                                                     2> /dev/null  > /dev/null
cd "$(dirname $0)"


shopt -s globstar


# now go and dump that database:
# 
# Record format:
# 
#     SHA1_fingerprint|extension="metadata"|MD5_checksum|info|extra=NULL
# 
# where info field WILL span multiple lines per record and has itself a JSON format!
# 
# The MD5_checksum field is the MD5 hash of the *exact* `info` blob contents, f.e.
# the example `3dd7bdd1517ad2bd59c0f75aa290d9a3.blob` file (binary copy of one info
# field a.k.a. 'data' column in the LibraryItem sqlite table) hashes to
# `3dd7bdd1517ad2bd59c0f75aa290d9a3`. The MD5 hash is stored in UPPERcase.
# 
# (Note that the `info` blob is essentially a JSON formatted text, where line breaks
# are encoded as CRLF (*not* LF only!); this should also be observable in the example
# blob file `3dd7bdd1517ad2bd59c0f75aa290d9a3.blob` when you inspect it with a hex/binary
# viewer.)
# 
# SHA1_fingerprint is the SHA1 hash of the related file contents (`DownloadLocation` field
# in the `info` blob JSON record). This fingerprint is echoed in the `info` JSON blob
# record in the `Fingerprint` field. At the time of this writing, we haven't yet tested
# what will happen to/with a record where these 'data columns' *differ*.
# 
# Note that an incorrect MD5 hash causes QIQQA to *DELETE* the entire record upon
# restart of the application! In other words: one mistake in your encoding/hashing
# and your *entire record will be nuked*. 
# 
# It also *seems* like QIQQA stores some sort of record count or some other truncation
# number as following such an encoding/hashing error the entire database still exists
# (minus the nuked records), but QIQQA doesn't show its contents anymore. This is
# under investigation at the time of this writing. Weird stuff... |:-S 
# 
# 
# 
# `info` field looks something like this:
# 
# {
#   "FileType": "pdf",
#   "Fingerprint": "60835FB1D237D8F3ED73653CC9F935FDD7FA16B1",
#   "DateAddedToDatabase": "20170711004707645",
#   "DateLastModified": "20170711004707645",
#   "DownloadLocation": "C:\\Program Files (x86)\\Qiqqa\\The Qiqqa Manual - LOEX.pdf",
#   "BibTex": "@article{qiqqatechmatters\n,\ttitle\t= {TechMatters: “Qiqqa” than you can say Reference Management: A Tool to Organize the Research Process}\n,\tauthor\t= {Krista Graham}\n,\tyear\t= {2014}\n,\tpublication\t= {LOEX Quarterly}\n,\tvolume\t= {40}\n,\tpages\t= {4-6}\n}",
#   "Title": null,
#   "Authors": null,
#   "Year": null,
#   "Tags": "help;manual",
#   "Comments": null,
#   "AutoSuggested_PDFMetadata": true,
#   "TitleSuggested": "TechMatters: \"Qiqqa\" than you can say Reference Management: A Tool to Organize the Research Process",
#   "AuthorsSuggested": "Krista Graham",
#   "YearSuggested": "2013",
#   "DateLastRead": null
# }
# 
# Note the BibTex field in there, which is a JSON-encoded BIBTEX record as entered in QIQQA.
# 
# 
# 
# The BIBTEX record from the example above actually reads like this:
# 
# @article{qiqqatechmatters
# ,       title   = {TechMatters: “Qiqqa” than you can say Reference Management: A Tool to Organize the Research Process}
# ,       author  = {Krista Graham}
# ,       year    = {2014}
# ,       publication     = {LOEX Quarterly}
# ,       volume  = {40}
# ,       pages   = {4-6}
# }
#
# It has a nice format like this because that's what happens when you hand-edit a bibtex record in QIQQA itself.
# 
# HOWEVER, an actual bibtex entry may be ANY TEXT, including stuff like this:
# 
#     @comment { BIBTEX_SKIP }
#     
# or even *INVALID* BIBTEX data! 
# (Qiqqa versions before 0.79 crashed on some half-baked bibtex-alike entries, such as '@delete()')
# 
# -------------------------------------------------------------------------------------
# 
echo "Dumping QIQQA database..."
echo "select * from LibraryItem;" | $SQLITEBINARY -list -nullvalue NULL -readonly $QIQQA_DB_BASE_DIR/Qiqqa.library > ./qiqqa_database_dump.txt

# also dump the other databases...
for f in copied_qiqqa_databases/*.library ; do
    echo "Dumping COPIED QIQQA database: ${f}..."
    echo "select * from LibraryItem;" | $SQLITEBINARY -list -nullvalue NULL -readonly "${f}" > "${f}.qiqqa_database_dump.txt"
done

 

# now process that dump into something that's easy to munch on in JavaScript:
# just do a simple transform using JavaScript.
echo "Processing QIQQA database dumps..."

# concatenate all dumps: the JS script will ultimately merge those infos for us!
cat ./qiqqa_database_dump.txt > ./qiqqa_database_dump_combined.txt
for f in copied_qiqqa_databases/*.qiqqa_database_dump.txt ; do
    cat "${f}" >> ./qiqqa_database_dump_combined.txt
done

node ./dump_qiqqa_sqlite_database.parse.js


echo "Patching QIQQA database..."
# $SQLITEBINARY $QIQQA_DB_BASE_DIR/Qiqqa.library < ./dump_qiqqa_sqlite_database.dbfixing.sql


popd                                                                                                        2> /dev/null  > /dev/null

