
var fs = require("fs");
var bibtexParse = require("zotero-bibtex-parse");
var crypto = require('crypto');


const DEBUG = 0;


function encode2sqlstring(str) {
	str = str.trim()
	.replace(/[']/g, "''");
	return "'" + str + "'";
}

function encode2sqllike(str) {
	str = str.trim()
	.replace(/[']/g, "''")
	.replace(/\s*[\r\n]\s*/g, "%");
	return "'%" + str + "%'";
}


fs.readFile("./dump_qiqqa_sqlite_database.dbfixes.txt", "utf8", function parseFixesList(err, data) {
	var lst = data.split(/^===============================+$/gm);
	var fixes = lst.map(function (data) {
		var record = data.split(/^-------------------------------+$/gm);
		if (record.length >= 2) {
			var mark = record[0];
			mark = mark.trim()
			.replace(/^BIBTEX PARSE ERROR:/, '')
			.replace(/[\r\n]bibtexParse error: [^]+$/, '')
			.trim();
			record[0] = mark;
		}
		return record;
	});
	if (DEBUG) console.log('FIXES:', fixes);

	var sql = fixes.map(function (record) {
		if (record.length >= 2) {
			return "UPDATE LibraryItem\nSET last_updated=\"123\", data=" + encode2sqlstring(record[1]) + "\nWHERE data LIKE " + encode2sqllike(record[0]) + ";";
		}
		return null;
	})
	.filter(function (stmt) {
		return !!stmt;
	});

	if (DEBUG) console.log("SQL STATEMENTS:", sql.join('\n\n\n'));

	fs.writeFileSync("./dump_qiqqa_sqlite_database.dbfixing.sql", '\n\n' + sql.join('\n\n\n') + '\n\n', "utf8");




	console.log('\n\n\n\n\n========================================================================\n\n\n\n\n\n');




	fs.readFile("./qiqqa_database_dump_combined.txt", "utf8", function parseDump(err, data) {
		/*
		# 
		# Record format:
		# 
		#     SHA1_fingerprint|extension="metadata"|MD5_fingerprint|info|extra=NULL
		# 
		# where info field WILL span multiple lines per record and has itself a JSON format!
		# 
		# `extension` field values: "metadata", "citations", ???
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
		*/
		var re = /^([A-F0-9]+)\|([^|]+)\|([A-F0-9]+)\|(\{[^]+?\})\|([^|\r\n]+)/gim;
		var lst = [];
		var match;

		while ((match = re.exec(data)) !== null) {
			var raw_blob = match[4];
			var info_blob = JSON.parse(raw_blob);
			var bibtex_info = null;
			var bib_in = info_blob.BibTex;

			try {
				if (bib_in) {
					bib_in = bib_in.replace(/\x1d/g, ' ');
					bibtex_info = bibtexParse.toJSON(bib_in);
				}
			} catch (ex) {
				console.log("\n\nBIBTEX PARSE ERROR:\n", info_blob.BibTex, "\nbibtexParse error: ", ex);
				bibtex_info = null;
			}

			// reconstruct the *actual* BLOB content as it was stored in the database:
			var real_raw_blob = raw_blob.replace(/[\r\n]+/g, '\r\n');
			// simile of the commandline: `openssl md5 -md5 xyz.blob`:
			var bibtex_hash = crypto.createHash('md5').update(real_raw_blob).digest("hex").toUpperCase();
			var md5 = match[3];

			if (md5 !== bibtex_hash) {
				console.log("\nDATA CONTENT DOES NOT MATCH ITS MD5 CHECKSUM:\n", {
					bibtex_hash,
					md5,
					real_raw_blob
				});
			}

			var sha1_fingerprint = match[1].toUpperCase();
			var sha1_fingerprint_copy = info_blob.Fingerprint.toUpperCase();

			if (sha1_fingerprint !== sha1_fingerprint_copy) {
				console.log("\nPDF FILE SHA1 HASH DUPLICATES DO NOT MATCH:\n", {
					sha1_fingerprint,
					sha1_fingerprint_copy,
					real_raw_blob
				});
			}

			lst.push({
				//match: match[0],
				sha1_fingerprint: sha1_fingerprint,
				extension: match[2],
				md5_fingerprint: match[3],
				info_blob: info_blob,
				bibtex: bibtex_info,
				extra: match[5],
				char_index: match.index,
			});
		}	
		fs.writeFileSync("./decoded.json5", JSON.stringify(lst, null, 2));
		console.log("record count: ", lst.length);
	});
});
