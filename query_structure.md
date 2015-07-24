# Query Structure

A Bookworm query is a JSON object with keys describing the objects to be fetched. Each key is essentially a function argument.
The syntax for queries is largely taken from MongoDB.

This definition is open for review, and will probably change before the 1.0 release.

I'm soliciting any comments. What statistics should be added? How should keys be arranged? What should they be named? Is the capitalization format driving you crazy?

## Overview

You can think of each of the query keys as doing one of four things:

1. **Filtering** the full library down to a set of interest;
2. **Grouping** that set by one or more metadata fields.
3. **Calculating** one more summary statistics for each of the groups defined by the previous set, either a count or a ratio
4. **Setting miscellaneous preferences** for how filtering, grouping, and calculating should be done.

Some of these take one key, some take a few.

## Filter keys

### `search_limits` (required: default `{}`)

`search_limits` is the workhorse function that lets you set the words or other fields to be searched. It has its own syntax: see 4.2.1 for details.

### `compare_limits` (optional)

Unlike `search_limits`, `compare_limits` is rarely specified manually, but when used it allows particularly complicated queries. Many queries contain an implicit comparison: you wish to return the number of times a word in a set is used *as a percentage of all the words used in that set*. `compare_limits` allows you to specify the comparison explicitly.

By default, `compare_limits` will be the same as `search_limits`, but with the `words` key removed: this makes it trivial to search for the percentage of all words.

But this is not always the most immediately useful comparison. If you want to compare how often two words are used, you can put one in search_limits and one in compare_limits.

## Grouping keys

### `"groups"`

`groups` is an array of metadata fields describing what metadata should be returned. Each entry represents an additional layer of complexity: for example, specifying `"groups":["year"]` will group only be year, while `"groups":["year","city"]` will group by both year and city.

Be very careful with the choices, because too many groups can quickly make a query unmanageable. If you have 100 of each, this could easily return a 10,000 row query. (Although interactions which do not exist in the source data will not be returned, so it will probably be somewhat lower.)

Possible fields include any of the user-defined metadata, as well as "unigram" or "bigram" to return wordcount data.

Grouping by "unigram" or "bigram" can be quite slow, and should only be attempted be attempted for the time being on subcorpora of, say, 1 million words or less at a time. (On larger corpora, you'll just up timing out.)


### Different groups for main query and comparison groups

Ordinarily, each ratio summary statistic ("Percentage of Books," say) refers directly to the interaction of group A and group B. Sometimes, this is less than useful.
Ordinarily a query like
`{"groups":["year","library"],"counttype":["TextPercent"]}`
will give for each interaction of year and library the number of texts that come from that particular library in that year. That's not interesting. (By definition, it will always be 100%.

On the other hand,

* `{"groups":["year","*library"],"counttype":["TextPercent"]}` will drop the library grouping on the superset and give the percentage of all texts for that year that come from the library, so each column will sum to 100%;
* `{"groups":["*year","library"],"counttype":["TextPercent"]}` will drop the year superset and give the percentage of all texts for that library that come from that year and library.
* Finally, `{"groups":["*year","*library"], "counttype":["TextPercent"]}` will drop **both** and give the percentage of all texts for the library defined by search_limits or constrain_limits contained in each cell: the sum of all the TextPercent cells in the entire return set should be 100. (Though it may not be if year or library is undefined for some items).


Combining this syntax with that for defining a separate `compare_limits` will produce some pretty nonsensical queries, so it's generally better to do just one or the other.


## Operation keys

### `"counttype"`

Example: `"counttype":["WordsPerMillion"]`

Counttype is an array of commands that specify what summary statistics will be returned.

The most commonly used values are:

* **WordCount**: The number of words matching the terms in `search_limits` for each group. (If no words key is specified, the sum of all the words in the book).
* **TextCount**: The number of texts matching the constraints on **search_limits** for each group.
* **WordsPerMillion**: The number of words in the search_limits per million words in the broader set. (Words per million, rather than percent, gives a more legible number).
* **TextPercent**: The percentage of texts in the broader group matching the search terms.

Also permanently available are:

* **TotalTexts**: The number of texts matching the constraints on **compare_limits**. (By selecting **TextCount** and **TotalTexts**, you can derive **TextPercent** locally, if you prefer).
* **TotalWords**: The number of words in the larger set.

Currently available, and useful in some specialized cases involving comparisons, are:

* **WordsRatio**: equal to `WordCount/TotalWords`
* **SumWords**: equal to `TotalWords + WordCount`
WordsRatio and TextRatio
* **TextRatio**: equal to `TextCount/TotalTexts`
* **SumTexts**: equal to `TextCount+TotalTexts`


## Miscellaneous settings:

### `database` (required: server-specific defaults)

Example: `{"database":"ChronAm"}`

A single server can contain several bookworms: this is a string describing which one to run queries on.

### `method` (required: default "return_json")

The type of results to be returned. For standard queries, this should be one of:

* **return_json**: a JSON-formatted result, consisting of nested dicts for each grouping in groups pointing to an array consisting of the results for each count in counttype.
* **return_tsv**: a tsv, with columns corresponding to each grouping in groups and each counttype in `counttype`.


There are also some special methods that overrride other settings:

* **returnPossibleFields**: gives a list of fields that can be used as `groups` or in `search_limits` with some data about their type. All fields but "database" are ignored.
* **search_results**: returns an array of html strings, each of which can be displayed to the user that matches the current `search_limits`. "Groupings" is ignored, and "counttype" is used in a special way (see `ordertype`). By default only the first 100 results are returned--there is currently no way to page past them.

### `ordertype` (default: dynamic)

**In progress: comments welcome**

When `method` is "search_results", the books are sorted before being returned. This sort ordering can be controlled.

By default, results are sorted by the **percentage of hits** in the text. That biases towards either texts that use the words a lot, or texts that use it rarely.

Often you want not the top texts, but some **representative texts**. For this purpose.

Currently, random sorting is handled in an interesting way. If the counttype relies on the *number or ratio of texts*, it sorts the texts in random order.

If the counttype relies on the *number of ratio of words*, however, it tries to sort the texts randomly weighted by the number of times the words appear in it. This means that **a random word from the first text should represent a random *usage* from the overall sample**.
The current MySQL-python implementation uses an approximation for this: `LOG(1-RAND())/sum(main.count)` that should mimic a weighted random ordering for most distributions, but in some cases it may not behave as intended.

> In progress. True weighted random ordering will be more expensive in time but potentially useful.


Depending on the usefulness of search ordering, this could be extended to support:
* TF-IDF ordering: weight results by the distinctiveness of words, not just raw frequency.

### `words_collation` (optional: default "case_sensitive")

Example: `"words_collation":"case_sensitive"`

A string representing how to handle case matching on the "words" term in groupings

Possible values:
* **case_sensitive**: match the string exactly as entered.
* **case_insensitive**: match case insensitive.
* **stem**: use the Porter stemming algorithm to find all words with the same stem: so "giraffes" will produce a hit when you search for "giraffe". Not supported on most new bookworms, but there are plans to restore it.

> **In progress**: I'm inclined to think this should be eliminated and instead users could specify 'casesens','case_insens' or 'stem' directly, and the API would translate the results appropriately. It's slightly uglier, but would allow more complicated queries (such as mixing case sensitive and insensitive in the same limits, or using separate values for groupings and search limits)

### Application-defined keys.

If you build a web or analysis app using Bookworm, you're encouraged to use the dict to add other keys storing other elements of the state. For example, the layout preferences for the D3 bookworm are stored in an `aesthetic` field which maps to a dictionary; and both GUIs use a field called `smoothingSpan` to represent smoothing.

The advantage of doing this is state persistence for RESTful apps, portability, and helpfulness for the logs.

#### Reserved keys

We may need to reserve a few keys for own use down the road. So if you do define something, avoid using the following unless you're contributing to a core project:

D3-bookworm reserved
* aesthetic

Future authentication needs
* key
* token
* user
