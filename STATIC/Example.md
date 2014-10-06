# An example workflow

You may have your own workflow, but let me suggest one potential way to make a Bookworm portable so that you can easily redeploy it across servers or upgrade it to new versions; saving all the creation scripts in a git repository designed to clone the latest bookworm into the level above it.

I'll use as an example the [Federalist papers bookworm](https://github.com/bmschmidt/federalist-bookworm), which adopts this format.

## 1. Create a git repository for the project

I like to name repositories after the collection with a hypen to Bookworm at the end: so this one is called `federalist-bookworm`. (Bookworm [plugins](Extensions.md), on the other hand, have bookworm first and then the functionality, if you're browsing my git repos.

The goal of this repository is that you can clone it to any computer and quickly rebuild the bookworm.

## 2. Make a makefile for the project.

That Makefile should have a few base targets.

Those are:
* `bookworm` -- a cloned version of the [backend repository](https://github.com/bmschmidt/Presidio)
* The three files required for the bookworm:
    * `bookworm/files/texts/input.txt`
    * `bookworm/files/metadata/jsoncatalog.txt`
    * `bookworm/files/metadata/jsoncatalog.txt/field_descriptions.json`
* A target like `bookwormcompleted` that causes the bookworm to actually be run.


For the Federalist example, I store input.txt and jsoncatalog.txt at the base level, and then simply copy them up; this makes it a little easier to see what's going on, or to delete the full repository if needed.

The main script that actually makes the inputs from the data we have on hand (here stored in the file "federalist.papers.XML" which has both data and metadata) is `parseXML.py`. The real work will go into making that script work right.

```
input.txt:
	python parseXML.py

#this one is redundant, but just for clarity:
jsoncatalog.txt: webpages
	python parseXML.py

```

The hardest of the three to script automatically is `field_descriptions.json`; probably you should just write that manually.

The last step in the Makefile relies on all the other files, and actually descends into the Bookworm folder to do a make. Note that although here it doesn't reuire the field_descriptions.json file explicitly, it creates it using the `scripts/guessAtDerivedCatalog.py` script. You can use that guessing script for a first stab, but I strongly recommend not just copying the file directly unless you know that and why it works.

```
bookwormdatabase: bookworm bookworm/bookworm.cnf bookworm/files/texts/input.txt bookworm/files/metadata/jsoncatalog.txt
	cd bookworm; git checkout lessDiskSpace;
	cd bookworm; python scripts/guessAtDerivedCatalog.py
	cd bookworm; make all
```
