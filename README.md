# qiqqa-revengin

reverse engineering the data stored by Qiqqa (bibtex database, etc.)

# IMPORTANT UPDATE @ 2019/JULY/14

Qiqqa has now been published as (GPL3 licensed) open source on GitHub at https://github.com/jimmejardine/qiqqa-open-source as announced [here](https://getsatisfaction.com/qiqqa/topics/open-source-qiqqa#reply_20199151).

This (private) reverse engineering work done in the years past is now public.

Do note that this repo is a bit, ah, "disorganized" in its root directory as this was a "*when there's time, work on bloody Qiqqa as it crashed once again, darn it*" labor of love. :smile:

# BASH shell scripts in this repo

Scripts are available to

- DUMP the Qiqqa (BibTeX / metadata) database

That's probably the most useful part of this work, apart from another script, which 

- goes through the Qiqqa library and seeks out all encrypted PDFs and PDFs which are not properly readable

  The built-in Qiqqa OCR left a few things to desire, so these PDFs are *decrypted* and then periodically fed through an external OCR batch process to produce similar PDFs which have the (properly) OCR'd text embedded for easier processing by Qiqqa. As both original PDF and decrypted/OCR-ed PDF have the same filename (which is the SHA1 hash of the original as calculated by Qiqqa), these PDFs should be easy to relate to one another in the Qiqqa database -- that bit of work has not been done yet as it turned out easier to manage the database in other tools, once Qiqqa had done the basic processing: my Qiqqa install (and re-install(s)!) all failed to produce a proper search index for even smaller libraries; seems Qiqqa was suffering from some sort of bit rot there, at least on my box. :cry:
  


# Database file format (as discovered via DB inspection)

Qiqqa uses a SQLite3 database with a very simple table structure: there's one table where all the files' BibTeX and other info is dumped in a single row per file, using a json(?) format which is verified against damage and tampering using SHA1 hashes.

See also the Qiqqa database dumper script: [`/dump_qiqqa_sqlite_database.sh`](https://github.com/GerHobbelt/qiqqa-revengin/blob/master/dump_qiqqa_sqlite_database.sh) and the workhorse underlying it: [/dump_qiqqa_sqlite_database.parse.js](https://github.com/GerHobbelt/qiqqa-revengin/blob/master/dump_qiqqa_sqlite_database.parse.js)

> Note that there are several files in the root dir of this repo with an SHA-hash embedded in their name: those sample records have been exttracted from a live Qiqqa DB and used to verify correct operation of the scripts.
>
> Now that Qiqqa is open sourced, a few still open questions can be answered. :smile:


## Record format:
 
     SHA1_fingerprint|extension="metadata"|MD5_checksum|info|extra=NULL
 
where info field WILL span multiple lines per record and has itself a JSON format!
 
 The MD5_checksum field is the MD5 hash of the *exact* `info` blob contents, f.e.
 the example `3dd7bdd1517ad2bd59c0f75aa290d9a3.blob` file (binary copy of one info
 field a.k.a. 'data' column in the LibraryItem sqlite table) hashes to
 `3dd7bdd1517ad2bd59c0f75aa290d9a3`. The MD5 hash is stored in UPPERcase.
 
 (Note that the `info` blob is essentially a JSON formatted text, where line breaks
 are encoded as CRLF (*not* LF only!); this should also be observable in the example
 blob file `3dd7bdd1517ad2bd59c0f75aa290d9a3.blob` when you inspect it with a hex/binary
 viewer.)
 
 SHA1_fingerprint is the SHA1 hash of the related file contents (`DownloadLocation` field
 in the `info` blob JSON record). This fingerprint is echoed in the `info` JSON blob
 record in the `Fingerprint` field. At the time of this writing, we haven't yet tested
 what will happen to/with a record where these 'data columns' *differ*.
 
 Note that an incorrect MD5 hash causes QIQQA to *DELETE* the entire record upon
 restart of the application! In other words: one mistake in your encoding/hashing
 and your *entire record will be nuked*. 
 
 It also *seems* like QIQQA stores some sort of record count or some other truncation
 number as following such an encoding/hashing error the entire database still exists
 (minus the nuked records), but QIQQA doesn't show its contents anymore. This is
 under investigation at the time of this writing. Weird stuff... |:-S 
 
 
 
 `info` field looks something like this:

```
{
  "FileType": "pdf",
  "Fingerprint": "60835FB1D237D8F3ED73653CC9F935FDD7FA16B1",
  "DateAddedToDatabase": "20170711004707645",
  "DateLastModified": "20170711004707645",
  "DownloadLocation": "C:\\Program Files (x86)\\Qiqqa\\The Qiqqa Manual - LOEX.pdf",
  "BibTex": "@article{qiqqatechmatters\n,\ttitle\t= {TechMatters: “Qiqqa” than you can say Reference Management: A Tool to Organize the Research Process}\n,\tauthor\t= {Krista Graham}\n,\tyear\t= {2014}\n,\tpublication\t= {LOEX Quarterly}\n,\tvolume\t= {40}\n,\tpages\t= {4-6}\n}",
  "Title": null,
  "Authors": null,
  "Year": null,
  "Tags": "help;manual",
  "Comments": null,
  "AutoSuggested_PDFMetadata": true,
  "TitleSuggested": "TechMatters: \"Qiqqa\" than you can say Reference Management: A Tool to Organize the Research Process",
  "AuthorsSuggested": "Krista Graham",
  "YearSuggested": "2013",
  "DateLastRead": null
}
```

**Note the BibTex field in there, which is a JSON-encoded BIBTEX record as entered in QIQQA.**
 
 
 
 The BIBTEX record from the example above actually reads like this:

```
@article{qiqqatechmatters
,       title   = {TechMatters: “Qiqqa” than you can say Reference Management: A Tool to Organize the Research Process}
,       author  = {Krista Graham}
,       year    = {2014}
,       publication     = {LOEX Quarterly}
,       volume  = {40}
,       pages   = {4-6}
}
```

It has a nice format like this because that's what happens when you hand-edit a bibtex record in QIQQA itself.
 
 HOWEVER, an actual bibtex entry may be ANY TEXT, including stuff like this:
 
     @comment { BIBTEX_SKIP }
     
 or even *INVALID* BIBTEX data! 
 (Qiqqa versions before 0.79 crashed on some half-baked bibtex-alike entries, such as `@delete()` - see https://getsatisfaction.com/qiqqa/topics/qiqqa-crash-on-next-startup-after-manual-editing-of-one-or-more-bibtex-records)
 
 -------------------------------------------------------------------------------------
 
