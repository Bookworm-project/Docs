# Extensions

There are a lot of logical ways to extend out Bookworm to work with established tools for text analysis. We want to make this easy without requiring enormous bloat in the core package.

## Installing/creating extensions.

The /extensions folder in a Bookworm is not created by default, but can be filled with folders; each folder is an installed extension.

Each extension should be a git repository that can be cloned into that extensions location. The single command `make` run in that directory should run the build; it's permissible for an extension to require command-line input.

That directory location means it will have access to your local bookworm configuration and other information. For example: once the geotagger builds its own metadata file,

```cd ../..; python OneClick.py supplementMetadataFromJSON extensions/geotagger/metadata.txt filename```

## Existing/under development Extensions

### Topic Modeling

The topic modeling extension adjusts the master wordcounts file so that each word has a topic assignment.

#### Challenges

1. Currently, it doesn't filter for stopwords, which is mathematically justifiable but hurts interpretability.
2. Should there be multiple topics run?

### The Bootstrapper.

It's hard to quantify the error associated with counts over time. [Bookworm-bootstrap](https://github.com/bmschmidt/Bookworm-Bootstrap) builds a bunch of different bootstrapped samples in which the same book can appear multiple times; that gives some sense of what random variation might be doing to your sample.

### The sampler

The bootstrapper lets you replicate sample error by drawing from your full sample: the [bookworm-samples](https://github.com/bmschmidt/Bookworm-samples) package simply creates a new dummy metadata variable for every single document in your set, assigning it to one of 100 groups.

This makes it possible to draw from a random distribution to see if the results you're getting are realistic.

### Geopositioner

Given the name of field that contains place names, add in a longitude-latitude formatted set of places.

Previously we stored latitude and longitude as separate fields. While there were a few nice features to that (you could search inside a bounding box), it was pretty inefficient compared to grouping on a single point. So now Bookworm stores all geolocation data as **json strings** consisting of latitude,longitude. So the location of New York City would be encoded as: `"[40.7127,-74.0059]"`.

You could probably also write that as `"[40.7127,285.9941]"`; but as a standard, we'll say that the negative numbers are the only supported one. (Unless someone tells me otherwise is better).


### Geotagger

The Geotagger will work by parsing a text using the Stanford NLTK named entity extractor, pulling out persons, locations, and entities. The results could then be run through the geopositioner plugin.

## Extensions we want

### The Linked Open Data interchange.

This would be the most amazing thing possible, and possibly worth building in as core funcationality. In essence: say you have a field `author_id`, and that corresponds to an identifier on some other page. By using a linked open data interchange, you could simply specify the source and the middle element of an RDF triple, and have the values automatically pulled in by some SPARQL process or something. The use of specific URIs in the `field_descriptions.json` field would enormously facilitate this.

### Serial Killer

Implement the Ngrams serial killer algorithm in Bookworm. Been done once, but might be a nice pocket example of how this can work on the OL/Hathi data.

### University Linker.

On my mind because of one Bookworm in particular, but with an academic audience it might be nice to have some pathway to populating texts that contain unstructured text of university names with all the data about universities in ICOADS.


### Genderation

Given a field that contains names (first or complete), add fields to the Bookworm that include gender both as a flat determination and as a probability. Ideally, should take some logic about the birth year of the person into account (19th century Leslies are male, etc.). Could be implemented using my old code, which is a bit more flexible, or Lincoln Mullen's R package, which I've used on one Bookworm.

## Strategies for handling data

### Accessing the raw text.

Extensions may access not just the database, but the raw creation files themselves.

Currently, a few extensions access the `input.txt` file. For example, in the geotagger extension:

```
metadata.txt:
	cat ../../files/texts/input.txt | parallel  --block-size 1M --pipe ./tagAChunk.sh > metadata.txt
```

This is clearly a bad idea, since it will break on other file storage techniques, we need to firmly define the `textStream` protocol for irregular bookworms, though, before this happens.

