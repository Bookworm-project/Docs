# Adding Hierarchical Data


## Philosophy

For understanding patterns, it's incredibly useful to be able to easily and quickly aggregate metadata into hierarchies.

Suppose you're looking at texts you have classified at the level of their "county."

There are a lot of different things you might want to do with that county-level information. A county is also part of state and a census region; it has a winner in the 2012 presidential election, and you might class it as urban, rural, or suburban.

The most straightforward way to do this sort of classification is just to include data like this for every entry in your Bookworm. Want to include election winner? Just have a field called `county_election_winner` in every catalog entry.

There's a reason, though, librarians don't store things like this on their cards: they would quickly get out of control. Even in a system like Bookworm, it's both inefficient and confusing to think of the election winner as being a property of the individual text: the election winner "belongs" to the county.

This is especially true if you want to update a Bookworm after the fact with some new information. (There are a lot, lot, lot of cases where this is incredibly valuable to do: frequently it's not until you begin data exploration that you'll know what useful patterns might be.) Generally, the data you'll want to put in will be not about the original texts, but about one of the metadata fields you already have.

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

Bookworm allows you to add **additional** data into the database once it's been created.

To do this, run `bookworm.py` with the add_metadata argument.

```bash
bookworm add_metadata \
    --file=yourfilename.txt \
    --field_descriptions=separate_field_descriptions.json
```

`file` is the new metadata: A full list of the available options can be seen in the shell by typing:

```shell
bookworm add_metadata --help
```

These include 'key', which is the metadata field that links into your existing database.

In general, the metadata here is handled in **exactly the same** way as the original metadata you supplied to bookworm. The format for the `field_descriptions` file is the same as the [field_descriptions.json](field_descriptions.json.html) file; the format for the file imported is identical to the format for the [jsoncatalog.txt file](JSONcatalog.html).

### Simpler import formats.

An much easier but less powerful method is to import a TSV file.

`bookworm add_metadata --format=tsv --file=filename.tsv`

This is just a convenience wrapper; the code will convert the tsv to a bunch of json entries; if you do not pass in a `key` argument it assumes the first column is the anchor field.

This makes it easy to quickly add new fields in the course of looking at data.

## Example: Rounding to years

For example, if you are looking at data that is categorized by a year field called `date_year`, you might find that the resolution is too high, and you want to view by **decade** instead.

To do that, you'd simply create a file at `~/misc/new_metadata.tsv` (or whatever, the name and location doesn't matter), like this:

```tsv
date_year    date_decade
[...]
1887    1880
1888    1880
1889    1880
1890    1890
1891    1890
1892    1890
[...]
```

Then go to your bookworm folder, and type in

```bash
bookworm add_metadata \
     --format=tsv \
     --file=~/misc/new_metadata.tsv
```

Once this is run, the database will have a new public field called `date_decade` that can be used by any API calls the same as `date_year`, but will aggregate at a higher level.


This particular trick--rounding a numberic variable--can be so handy that I'll give you a little shell script for doing it by any number on any variable at all.

```bash
# Variables you might change
floor_to_nearest=10;
old_variable=year
new_variable=decade
database=SOTU

# Print headers for the tsv
echo -e "$old_variable\t$new_variable" > new_data.tsv

# Download all of the year variables through the API, and round them
# using awk.

curl -G localhost/cgi-bin/dbbindings.py --data-urlencode "query={\"database\":\"$database\",\"groups\":[\"$old_variable\"],\"counttype\":[\"WordCount\"],\"method\":\"return_tsv\"}" |
   awk "BEGIN{OFS=\"\t\"} \
   {if(NF==2) {\
     print \$1,$floor_to_nearest*int(\$1/$floor_to_nearest)\
   }}" >> new_data.tsv

bookworm add_metadata \
     --format=tsv \
     --file=new_data.tsv

```
