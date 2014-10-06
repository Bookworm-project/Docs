# search_limits and compare_limits

## Introduction

The most powerful aspect of bookworm is its ability to filter down to a custom set of fields. This is done by setting a number of constraints on `search_limits` or `compare_limits` fields.


### Note

As described in 4.2, `search_limits` and `compare_limits` both take the same syntax: for this section, I'll just use `search_limits` but understand that they mean both.


## Predefined limiting keywords

Every bookworm may have different metadata fields: these examples are for a fictitious database of books.

A few keys should be supported in all bookworms, though:

* Word searches

    * The one term that is pre-defined in (almost) all bookworms is the term `"word"` (which matches, despite its name, any phrase up to the number of supported grams).
    * `unigram` or `bigram` can be used as a synonym for word. This is particularly useful in searching for groups.
    * `hasword` can limit the search to only books that containing the specified word. (Not currently supported, but part of the specification)
        * > It's possible this should be retitled `$hasword` from `hasword` to better match the syntax below.

> There should also be a syntax built in to support **proximity** searches: these are not possible under MySQL, but will be under Solr.

I'd suggest something along the lines of `{"near":["foo",5]}` where foo is the word and five is the proximity range.

## Categorical limits.

To limit a query categorically, pass an array consisting of the allowed keys. For example, to limit to women and books published in the United States or Germany in 1890, pass

```
"search_limits":{
    "author_gender":["Female"],
    "country":["United States","Germany","East Germany","West Germany"],
    "publish_year":[1890]
    }
```

Queries bounded in an array are by default treated as an "or" construction within the array: documents matching any limit will be returned.

Each of the elements, on the other hand, is treated as an `AND` construction: returned documents must match at least one item for EACH of the keys entered.

If a string or numeric value is passed rather than an array, the API will automatically convert that to a single-element array.

### Categorical limits, long form

An alternate way to express categorical limits is to use a dictionary rather than array, and pass the special "$eq" key as a value pointing to the limitations. The above query could also be written as:
```
"search_limits":{
    "author_gender":{"$eq":"Female"},
    "country":{
        "$eq":["United States","Germany","East Germany","West Germany"]
        },
    "publish_year":{"$eq":1890}
    }
```

This long syntax is borrowed from MongoDB. It is verbose and not useful for most queries: but is provided for completeness because more complicated API calls require other keys (such as `"$ne"`) which take the same form.

## Exclusion

To define a search by **negative** matches, you can pass a hash rather than an array and use the special key "$ne". So to search for books published **outside** the United States or Canada, you would pass:

```
{"country":{"$ne":["United States","Canada"]}}
```

An "$ne" limitation will reject any books published in *either* of those places.

## Range limits

Numeric values can also be searched with range queries. The syntax for this is to pass a hash and use special keys from the following list:

* **`$gte`** Greater than or equal to
* **`$gt`** Greater than
* **`$lte`** Less than or equal to
* **`$gt`** Less than

So to limit to books published between 1900 and 1950, **either** of the following two queries would work:

```
{"publish_year":{"$lte":1950,"$gte":1900}
{"publish_year":{"$lt":1951,"$gt":1899}
```

## And/Or limitations

More complicated boolean statements are possible by using the special `$or` construction. (This syntax is also borrowed from MongoDB). `$or` points to an array, **any element of which might be true**. To search for books that are either published in the US or by US-born authors, for example, you might limit as follows:

```
{"$or":[
      {"country":["USA"]},
	  {"author_birth_country":["USA"]}
]}
```

`$and` is the opposite of `$or`: so the following query:

```

"search_limits":{"$and":[{"country":["USA"],"author_birth_country":["USA"]}]}
```

would return all books published both in the United States and by American-born authors. This and-construction will never be necessary in a base-level search, because all grouped limitations are and-queries by default: the above is exactly equivalent to

```
"search_limits"{"country":["USA"],"author_birth_country":["USA"]}
```

Like `"$eq"` (above), `"$and"` is included for completeness and so that it can specified in deeply nested queries.

## Complicated queries.

These constructions can be nested arbitrarily to create complicated combinations of "and" and "or" queries. To construct a query, for example, that encompasses authors whose political party is the same as the sitting US president's in the last few decades, you might type the following monstrosity:

```
"search_limits":{
    "$or":[
        {
            "year":{
                "$or":[
                    {"$gte":1980,"$lte":1992},
                    {"$gte":2001,"$lte":2008}
                    ]
                },
            "author_party":"Republican"
        },
        {
            "year":{
                "$or":[
                    {"$gte":1993,"$lte":2000},
                    {"$gte":2009}
                    ]
            },
            "author_party":"Democrat"
        }
    ]
}

```


## Regular Expressions

You can also limit by regular expressions rather than complete matches by using the "$grep" key.

MySQL-supported regular expressions can be used. To match any of several spellings of the publisher "Little, Brown" you might search for:

```
"search_limits":{"publisher":{"$grep":"Little,? Brown ((and|&) ?[Cc]o\.?)?"}

```

Yuck, huh?

> Question: Should this be retitled `$re`?

## Open questions.

Should it be possible to limit not just by results, but by counttypes? For instance, to only return results where the specified groups have a wordcount over 10, you could search:

"search_limits":{"WordCount":{"$gte":10}}
