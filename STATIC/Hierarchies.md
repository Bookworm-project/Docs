# Adding Hierarchical Data


## Philosophy

For understanding patterns, it's incredibly useful to be able to easily and quickly aggregate.

Suppose you're looking at texts you have classified at the level of their "county."

There are a lot of different things you might want to do with that county-level information. A county is also part of state and a census region; it has a winner in the 2012 presidential election, and you might class it as urban, rural, or suburban.

The most straightforward way to do this sort of classification is just to include data like this for every entry in your Bookworm. Want to include election winner? Just have a field called `county_election_winner` in every catalog entry.

There's a reason, though, librarians don't store things like this on their cards: they would quickly get out of control. Even in a system like Bookworm, it's both inefficient and confusing to think of the election winner as being a property of the individual text: the election winner belongs to the county.

This is especially true if you want to update a Bookworm after the fact with some new information. (There are a lot, lot, lot of cases where this is incredibly valuable to do: often you won't know what the useful patterns are until you've started to explore the data). Generally, the data you'll want to put in will be not about the original texts, but about one of the metadata fields you already have.

```
county
    |
    state
        |
        census region
    |
    urban, rural, or suburban
    |
    winner in 2012 presidential election
```

## Implementation

The bookworm code exposes some methods to add **additional** data into the database once it's been created. It can be deployed from instead a BookwormSQLDatabase() object, or invoked from the command line using:

`python OneClick.py supplementMetadataFromJSON $file $key `

(where $key and $file are parameters you must pass.)

### TSV import

An easier but less powerful method is to import a TSV file.

`python OneClick.py supplementMetadataFromTSV`

This is just a convenience wrapper; the code will convert the tsv to a bunch of json entries, and it assumes the first column is the anchor field.
