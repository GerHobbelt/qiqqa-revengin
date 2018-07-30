

UPDATE LibraryItem
SET last_updated="123", data='@book{semiconductor2012igbt,
  title={HBD871/D: IGBT Applications (Handbook)},
  author={Semiconductor, ON},publisher={ON Semiconductor},
  year={2014}
}'
WHERE data LIKE '%@book{semiconductor2012igbt,%title={HBD871/D: IGBT Applications (Handbook)},%author={Semiconductor, ON},publisher={ON Semiconductor}%year={2014}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@book{semiconductor2014power,
  title={HBD853/D: Power Factor Correction (PFC) Handbook-Choosing the Right Power Factor Controller Solution (5th edition)},
  author={Semiconductor, ON},
  publisher={ON Semiconductor},revision={5},
  year={2014}
}'
WHERE data LIKE '%@book{semiconductor2014power,%title={HBD853/D: Power Factor Correction (PFC) Handbook-Choosing the Right Power Factor Controller Solution (5th edition)},%author={Semiconductor, ON},%publisher={ON Semiconductor},revision={5}%year={2014}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@article{handout2007introduction,
  title={CS143: Handout 13: July 8, 2005: Introduction to yacc and bison},
  year={2005},
  author={Johnson, Maggie and Zelenski, Julie}
}'
WHERE data LIKE '%@article{handout2007introduction,%title={CS143: Handout 13: July 8, 2005: Introduction to yacc and bison},%year={2005}%,author={Johnson, Maggie and Zelenski, Julie}%';


UPDATE LibraryItem
SET last_updated="123", data='@delete{delete,
  title={delete},author={delete},year={delete}
}'
WHERE data LIKE '%@delete { delete }%';


UPDATE LibraryItem
SET last_updated="123", data='@article{cokol2007many,
  title={How many scientific papers should be retracted?},
  author={Cokol, Murat and Iossifov, Ivan and Rodriguez-Esteban, Raul and Rzhetsky, Andrey},
  journal={EMBO reports},
  volume={8},
  number={5},
  pages={422--423},
  year={2007},
  publisher={EMBO Press}
}'
WHERE data LIKE '%@article{cokol2007many,%title={How many scientific papers should be retracted?},%author={Cokol, Murat and Iossifov, Ivan and Rodriguez-Esteban, Raul and Rzhetsky, Andrey},%journal={EMBO reports},%volume={8},%number={5},%pages={422--423},%year={2007},%publisher={EMBO Press}%also_contains={@article{garvalov2007mobility,%title={Mobility is not the only way forward},%author={Garvalov, Boyan K},%journal={EMBO reports},%volume={8},%number={5},%pages={422},%year={2007},%publisher={European Molecular Biology Organization}%}}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@phdthesis{alu01,
  title={开关电源中铝电解电容 ESR 实时估测 (Aluminum electrolytic capacitor ESR real-time estimation for switching power supply)},
  author={王国辉 and 关永 and 郑学艳 and 吴立锋 and 潘巍},
  year={2014}
}'
WHERE data LIKE '%@phdthesis{王国辉2014开关电源中铝电解电容,%title={开关电源中铝电解电容 ESR 实时估测 (Aluminum electrolytic capacitor ESR real-time estimation for switching power supply)},%author={王国辉 and 关永 and 郑学艳 and 吴立锋 and 潘巍},%year={2014}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@delete{delete,
  title={delete},author={delete},year={delete}
}'
WHERE data LIKE '%@delete { delete }%';


UPDATE LibraryItem
SET last_updated="123", data='@appnote{???,
  title={Relays and switches: Contact Arc Phenomenon},
  publisher={Tyco Electronics},
  year={???},
  author={???}
}'
WHERE data LIKE '%@appnote{???,%title={Relays and switches: Contact Arc Phenomenon},%publisher=Tyco Electronics},%year={???},author={???}}%';


UPDATE LibraryItem
SET last_updated="123", data='@delete{delete,
  title={delete},author={delete},year={delete}
}'
WHERE data LIKE '%@delete{}%';


UPDATE LibraryItem
SET last_updated="123", data='@empty{empty,
  nontitle={empty},nonauthor={empty}
}'
WHERE data LIKE '%@empty{}%';


UPDATE LibraryItem
SET last_updated="123", data='@collection{isiamov1,
  title={Invited papers and accepted abstracts presented at the International Symposium on Innovations and Advancements in the Monitoring of Oxygenation and Ventilation (1SIAMOV 2007) convened at Duke University on March 15- 17, 2007},
  note={These papers and abstracts were published in December, 2007 as a supplement issue of the journal Anesthesia & Analgesia 105 (6S_Suppl)},
  editor={Philip E. Bickler, MD, PhD: Professor in Residence, University of California at San Francisco Medical Center},
  year={2007}
}'
WHERE data LIKE '%@collection{isiamov1,%title={Invited papers and accepted abstracts presented at the International Symposium on Innovations and Advancements in the Monitoring of Oxygenation and Ventilation (1SIAMOV 2007) convened at Duke University on March 15- 17, 2007},%note={These papers and abstracts were published in December, 2007 as a supplement issue of the journal Anesthesia & Analgesia 105 (6S_Suppl)},%editor={Philip E. Bickler, MD, PhD: Professor in Residence, University of California at San Francisco Medical Center}%year={2007}}%';


UPDATE LibraryItem
SET last_updated="123", data='@delete{delete,
  title={delete},author={delete},year={delete}
}'
WHERE data LIKE '%@delete{呂錦山2009台灣地區國際商港永續經營與發展之研究,%title={台灣地區國際商港永續經營與發展之研究},%author={呂錦山 and 桑國忠},%year={2009}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@book{mitrinovic1996handbook
,       title   = {Handbook of number theory}
,       author  = {Mitrinovi\''c, D.S. and S\''andor, J. and Crstici, B.}
,       volume  = {1}
,       year    = {1996}
,       publisher       = {Kluwer Academic Pub}
}'
WHERE data LIKE '%@book{mitrinović1996handbook%,       title   = {Handbook of number theory}%,       author  = {Mitrinovi\\''c, D.S. and S\''andor, J. and Crstici, B.}%,       volume  = {1}%,       year    = {1996}%,       publisher       = {Kluwer Academic Pub}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@article{whelan2010
,       author  = {Whelan, Robert}
,       title   = {Effective analysis of reaction time data}
,       journal = {The Psychological Record}
,       year    = {2010}
,       volume  = {58}
,       number  = {3}
,       pages   = {9}
}'
WHERE data LIKE '%@article{whelan 2010 effective czas reakcji latency rt%,       author  = {Whelan, Robert}%,       title   = {Effective analysis of reaction time data}%,       journal = {The Psychological Record}%,       year    = {2010}%,       volume  = {58}%,       number  = {3}%,       pages   = {9}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@comment { BIBTEX_AUTO - GS }
@article{hermans2012exact,
  title={Exact and near-miss clone detection in spreadsheets},
  author={Hermans, Felienne},
  journal={TinyToCS},
  volume={1},
  year={2012}
}'
WHERE data LIKE '%@comment { BIBTEX_AUTO - GS }%@article{hermans2012exact,%title={Exact and near-miss clone detection in spreadsheets},%author={Hermans, Felienne},%journal={TinyToCS$\}$},%volume={1},%year={2012}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@book{hopcroft2001automata,
  title={Introduction to automata theory, languages, and computation},
  author={Hopcroft, John E and Motwani, Rajeev and Ullman, Jeffrey D},
  year={2001},
  publisher={Addison-Wesley}
}'
WHERE data LIKE '%@book{hopcroft2001automata,%title={Introduction to automata theory, languages, and computation},%author={Hopcroft, John E and Motwani, Rajeev and Ullman, Jeffrey D},%year={2001},%publisher=Addison-Wesley}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@specsheet{DHM3UM80,
  title={DHM3UM80: High Voltage Fast Recovery Diode},
  manufacturer={Hitachi}
}'
WHERE data LIKE '%@specsheet{%title={DHM3UM80: High Voltage Fast Recovery Diode},%manufacturer={Hitachi}%}%';


UPDATE LibraryItem
SET last_updated="123", data='@comment { BIBTEX_AUTO - GS }
@article{abraham2014fully,
  title={Fully Dynamic All-Pairs Shortest Paths: Breaking the O(n) Barrier},
  author={Abraham, Ittai and Chechik, Shiri and Talwar, Kunal},
  journal={Approximation, Randomization, and Combinatorial Optimization. Algorithms and Techniques (APPROX/RANDOM 2014)},
  volume={28},
  pages={1--16},
  year={2014},
  publisher={Schloss Dagstuhl--Leibniz-Zentrum fuer Informatik}
}'
WHERE data LIKE '%@comment { BIBTEX_AUTO - GS }%@article{abraham2014fully,%title={Fully Dynamic All-Pairs Shortest Paths: Breaking the O (n) Barrier$\}$$\}$},%author={Abraham, Ittai and Chechik, Shiri and Talwar, Kunal},%journal={Approximation, Randomization, and Combinatorial Optimization. Algorithms and Techniques (APPROX/RANDOM 2014)$\}$},%volume={28},%pages={1--16},%year={2014},%publisher={Schloss Dagstuhl--Leibniz-Zentrum fuer Informatik$\}$}%}%';

