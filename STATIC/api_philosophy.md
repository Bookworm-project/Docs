# API Philosophy

The Bookworm API aims to be a general purpose scheme for describing data to be used in text analysis and visualization. It does only simple calculations, and returns data in TSV or JSON format.

## The primary goal is information about the metadata, not the individual texts

Normal search engines are very good at finding individual texts: Bookworm is good at finding and understanding **categories** in a libary. The simplest use case is returning **usage of a word across years**: the goal here is to understand something about the years through the words they use, or about the

## Metadata can be many things, including word counts

Bookworm returns informations about word and phrase usage, treating these as *additional metadata about the text*. Since words are more metadata, anything you can do with metadata, you should be able to do with word or phrase counts. Rather than get the counts of a single word across all years, for instance, you can also return the counts of all words across a single year.

But though wordcount information is the most valuable and the most novel metadata available through the API, it's not completely necessary: many useful queries will describe the contents of the library as a whole without using the wordcount information at all. ("What percent of books were written by women in 10 countries?")

By providing a general API for this sort of information,

## Arbitrarily complex queries should be supported.

The interactions between metadata can be very complicated: Bookworm aims to support very complex queries to describe relations.

That means things like multilevel hierarchies

## Underlying texts should be immediately accessible in ways that help explain the distribution.

Although the primary methods return aggregate information, Bookworm also link link back to the text underneath. That means returning bibliographic information and, ideally, a link or some other way of reading full text.

Unlike some other forms of "big data" (weather observations, say, or particle collider readings) the individual sources of data for a bookworm carry rich meanings. Text collections usually have complicated strata of biases that have accreted over years of composition, collection, and digitization; the titles or contents of texts are invaluable to see what's going on.

Since the goal is understanding the contents of the collection, not just returning individual texts, there need to be more ways to explore results than just ordered list. To see how a word is used, for instance, it is sometimes as important to see books that use it once as books that use it a dozen times. Appropriate forms of random return are also necessary.
