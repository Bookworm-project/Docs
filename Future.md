# Future Plans

## Bookworm and TEI/XML

TEI (and XML more generally) contains rich data about individual portions of a text.

## Bookworm and Linked Open Data

The current field_descriptions.json format could be supplemented or avoided by having some way to define keys through RDF triples. So instead of "date," one could use `http://bookworm.culturomics.org/date`, or `purl.org/dcterms/date`, or whatever the proper syntax for this is.

Unfortunately,

## Bookworm and SOLR

Integration with SOLR makes an enormous amount of sense: Solr handles text queries very well, and is getting increasingly good at things like faceted queries. It makes things like proximity search possible for the first time. Both engines take a very long time to build indexes, but Solr may be better at adding new indexes.

### Needs before moving to SOLR.
There are a number of things possible in MySQL that I (Ben) want to make sure we preserve before moving over to a Solr solution altogether, because I think they are enormously important for a variety of research.

1. **Faceted queries.** Earlier versions of Solr didn't make multidimensional responses possible: they can be replicated through lots of smaller searches, but this is the single most important thing in making Bookworm a text analytics engine, not just a search engine.
2. **Returning Word counts and Text counts**. In some cases it's appropropriate to count words and not texts; in other cases, the opposite is the case. Default Solr implementations have simply returned the number of texts with a match; this is not acceptable for real quantitative analysis, particular in heterogeneous corpora where text length may differ greatly.
3. We also should be able to group by words (or lowercase, etc).
3. **Live stemming and capitalization**. AFAIK, Solr does its stemming before

