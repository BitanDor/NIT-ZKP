# NIT-ZKP

This repository contains the materials used and tools developed working on the paper **Using Zero-Knowledge to Reconcile Law Enforcement Secrecy and Fair Trial Rights in Criminal Cases** by _Dor Bitan, Ran Canetti, Shafi Goldwasser, and Rebecca Wexler_. [(link to pre-print version)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4074315).


##Repository contents

**BitTorrent Demos** contains the relevant material for generating the virtual network for our toy demos, and the demos. 


**Cairo text-processing tolls** contains the Cairo check-program that checks the main component of the source code for compliance with hardcoded black-list and white-list and hash check (and other checks).  It also contains Cairo tools for computing the bag-of-words of a text file. For more info on installing Cairo, writing and compiling Cairo programs, and generating and proving STARK proofs, see [this link](https://www.cairo-lang.org/).


**The initializer** contains our script that processes a text file into a cairo readable format. 


**Wrapper auto generation** creates a python code for auto generation of the Cairo-check program from hard-coded black-list and white-list (and count-list). It also contains the template from which the check-program is built. 


**Legal Docs** contains a legal document mentioned in our paper. 

##Please note:
Code references in our scripts are currently **local** and hence **have to be modified** by whoever tries to use them. 



