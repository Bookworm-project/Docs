# Building a Bookworm

##Overview

Building a Bookworm requires a working knowledge of the command line, the ability to install software packages, and (generally) root access to the machine you're working with.

From a sysadmin perspective, it's about the same difficulty as installing a working version of Wordpress on your local machine. If that sounds onerous, you might want to [try the free hosting provided by the Rice Cultural Observatory](http://bookworm.culturomics.org) or get in touch with us to find someone who can set up a private server on Amazon for you.

It also requires, usually, some data munging to get the files into an appropriate format to work with.

## System/software Requirements

#### Operating System:

Bookworm installations are best tuned for recent versions of Ubuntu. Development versions are also maintained on Mac OS X. Other Unixes should be usable without much trouble: some files for configuring CentOS are included in the distribution, although they may be out of date. Windows is out of the queston.

#### Software Dependencies:
* MySQL 5.6 or later.
    * (MySQL 5.5 will work in most cases, but will not be supported going forward and may break with future updates.)
* Python 2.7, plus the modules:
    * regex
    * nltk
* GNU parallel
    * Which in some versions throws some extremely obnoxious warnings about how you have to cite it if using it: feel free to, but remember that the distribution includes many other software tools (python, MySQL, Bookworm itself) that are more fundamental to its operation than this tool.
* Apache2 (or another web server of your choice.)

## Hardware requirements

### RAM

Bookworm queries run fast because large amounts of memory is stored in memory. With some tweaking, one can create a disk-based Bookworm; these are not supported by default because they tend to be signficantly slower.

How much RAM does Bookworm need?

It depends on a lot of things, like how big the bookworm you're building is: but 4GB, let's say? There may be problems with lots of processors and low RAM; in these cases, the line in the Makefile setting the parallel chunk size.

A running installations also stores a number of files in memory. Several different bookworms running simultaneously on a server might take up a few gigs of memory. That is to say, you might be able to test it off an old laptop or an AWS micro instance, but you probably don't want to serve it from there.

### Hard Drive space

The other reason for Bookworm's speed at present is a number of B-tree indexes on every possible phrase that a user might search for. This is a very disk-consuming sort of storage, so bookworms frequently take up significantly more space than the texts fed into them.

Intermediate creation take up quite a bit of space in most Bookworm repos, though less than in earlier versions.

So, how much disk space does Bookworm need?

Bookworm is quite disk-space intensive, to get the fastest possible lookups on the user end. I'll give an absolute worse-case scenario to test the limits here. If you're doing texts that are larger than these (here, the average text length is 43 words), the bloat will not be so bad. (Because the number of **distinct** words in the text increases as log(n), where n is the number of words in the text).

**As an upper limit,** take one very metadata-heavy corpus: each text is under a paragraph long with about 14 million texts. This means that the Bookworm file stroage will be at its worse; the tokenized wordcounts will usually be longer than the original documents, which is very rarely the case.

## For a build.

The pure text files are 3 gigabytes: the intermediary files take up 56GB altogether. THe largest are the metadata (which in this case includes a couple different copies of each individual text); next are the binaries and the encoded load files, at about 5x the original files.

```
2.8G input.txt
14G	 files/texts/encoded
16G	 files/texts/binaries
23G	 files/metadata
229M	 files/texts/textids
114M	 files/texts/wordlist
118M	 files/texts/binaries/completed
33G	 files/texts
56G	 files
```

The new, unstable `lessDiskSpace` branch gets rid of the documents in files/texts/binaries.

## Plus the database.

The database itself, if on the same machine, is another 42GB; and because MySQL needs scratch spaces for indexes, this particular example would need another 15GB available as scratch.

## For final storage

The final database takes up 42 GB. The largest files are the unigram **indexes**, which are 3x the size of the unigram **words**. (That's because under the hood, the index is really two full copies of all the data; one sorted as `bookid,wordid,count` and the other sorted as `wordid,bookid,count`)

```
-rw-rw---- 1 mysql mysql  13G Apr 16 17:42 master_bookcounts.MYI
-rw-rw---- 1 mysql mysql 9.3G Apr 16 17:54 master_bigrams.MYI
-rw-rw---- 1 mysql mysql 6.5G Apr 16 17:45 master_bigrams.MYD
-rw-rw---- 1 mysql mysql 4.9G Apr 16 21:30 catalog.MYD
-rw-rw---- 1 mysql mysql 4.1G Apr 16 17:33 master_bookcounts.MYD
-rw-rw---- 1 mysql mysql 4.0G Apr 18 13:26 catalog.MYI
-rw-rw---- 1 mysql mysql 115M Apr 18 13:26 nwords.MYI
-rw-rw---- 1 mysql mysql  99M Apr 16 18:07 nwords.MYD
-rw-rw---- 1 mysql mysql  43M Apr 16 17:31 words.MYD
```


**As a lower limit,** take the Open Library corpus, which is very long individual texts.

That is 1,000,000 documents; the final results take up 1.5TB on disk for the MySQL tables alone.

So a 100,000 book bookworm might take more like 150 GB for storage.


## Is this too much?

The structuring principle here has been that hard drive space is cheap, and user speed matters. There are a lot of optimizations possible that may slightly increase build time, but require susbstantially less space in the build. For the final storage, the ratio is different.


