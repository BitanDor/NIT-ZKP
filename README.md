# NIT-ZKP

This repository contains the materials used and tools developed working on [this paper](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4074315).


**BitTorrent Demos** contains the relevant material for generating the virtual network and for our toy demos. 


**Cairo text-processing tolls** contains the Cairo program that is used to check the main component of the source code for compliance with hardcoded black-list and white-list and hash check (and other checks).  It also contains Cairo tools for computing the bag-of-words of a text file. 


**Legal Docs** contains a legal document mentioned in our paper. 


**The initializer** contains our script that processes a text file into a cairo readable format. 


**Wrapper auto generation** creates a python code for auto generation of the Cairo-check program from hard-coded black-list and white-list (and count-list). It also contains the template from which the check-program is built. 

Code references in scripts are currently **local** and hence **have to be modified** by whoever tries to use them. 
For more info on installing Cairo, writing and compiling Cairo programs, and generating and proving STARK proofs, see [this link](https://www.cairo-lang.org/).

