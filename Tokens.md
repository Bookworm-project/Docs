# Defining a Token

Language analysis needs to tokenize words. There's no single tokenization that will please everyone, but we use one that works pretty well on English-language texts from the last 200 years or so. It's long, though, and can probably use a few sets of eyes. Plus, there may be a certain type of person who enjoys reading long descriptions of regular expressions. Bookworm tokenizes using a rather complicated regular expression designed to approximate, as closely as possible, the method used for the 2009 Michel-Aiden Science paper and the accompanying resource, Google Ngrams.

We don't use the 2012 methods in the later ngrams corpora because they include a number of strange optimizations, such as [tokenizing "won't" to "will not"](https://books.google.com/ngrams/graph?content=won%27t%2Cwill+not&year_start=1800&year_end=2000&corpus=15&smoothing=3&share=&direct_url=t1%3B%2Cwill%20not%3B%2Cc0%3B.t1%3B%2Cwill%20not%3B%2Cc0).

The full regular expression is defined in the python code as the following (as of April 20014).

This tokenization may change, so let us know if there are any changes you'd like to see.

The final compiled regex compiles looking for the most complicated token-matching strings first, and as it goes on finds simpler and simpler forms, but I'll break it down in reverse order. We look for words, numbers, and then, finally, punctuators.

### "word" regexes

The base word regex is simply any number of consecutive unicode letters:

```
MasterExpression = ur"\p{L}+"
```

Contractions that end in `'s` or `n't` should be tokenized as words. (Note that in dirty OCR text this may tokenize a few dirty or foreign language strings like `the'soft` into `the's` `oft`: it may be desirable to make this off-toggleable for non-English text).

```
possessive = MasterExpression + ur"'s"

possessive2 = MasterExpression + ur"n't"
```

There are also a number of special-case abbreviations that are tokenized to keep their trailing period.

```
abbreviation = r"(?:mr|ms|mrs|dr|prof|rev|rep|sen|st|sr|jr|ft|gen|adm|lt|col|etc)\."
```

Finally, the sharp sign is attached to the preceding letter when it is between A and G (which are musical notes) or is J or X. (Terms from computer science).

```
sharps = r"[a-gjxA-GJX]#"
```

### "number" regexes
The basic number regex is simply `[\d+]`: any number of arabic numerals. Assuming that's easy enough to understand, I'll jump straight to the lookahead version that allows any number to be preceded by one of a few currency signs.

```
numbers = r"(?:[\$£€¥])?\d+"
```

In American English, a number can also have any number of triple-grouped digits preceded by a comma.

```
thousandGroup = r"(?:,\d\d\d)"

numbers = "%s%s*" %(numbers,thousandGroup)
```

A decimal is simply a number, followed by a period followed by more numbers.

```
decimals = numbers + r"\.\d+"
```

We could but do not support European-style numbers. So `$4,000,000.23` will be tokenized as a single word, but `€4.000.000,23` will be tokenized as `€4.000` `.` `000` `,` `23`

### punctuators

Unless otherwise specified, all punctuation marks are **retained** one at a time. (This differs from many other tokenizers).

### The master regex.

This code is implemented in python as follows. One note: this requires the python `regex` module to support unicode regular expression phrases such as `\p{L}` (which matches any unicode letter in any language, and forms the basis for the codes below). So although some of the code below *appears* to use the `re` module, the prefix (in `bookworm/tokenizer.py`).

``` {python}
import regex as re

MasterExpression = ur"\p{L}+"
possessive = MasterExpression + ur"'s"
possessive2 = MasterExpression + ur"n't"
numbers = ur"(?:[\$£€¥])?\d+"
thousandGroups = ur"(?:,\d\d\d)*"
numbers = numbers + thousandGroups
decimals = numbers + ur"\.\d+"
abbreviation = ur"(?:mr|ms|mrs|dr|prof|rev|rep|sen|st|sr|jr|ft|gen|adm|lt|col|etc)\."
sharps = ur"[a-gjxA-GJX]#"
punctuators = ur"[^\p{L}\p{Z}]"

bigregex = re.compile("|".join([decimals,numbers,abbreviation,possessive,possessive2,sharps,punctuators,MasterExpression]),re.UNICODE|re.IGNORECASE)
```

For example: paste that into python and run:

```
re.findall(bigregex,u"Mr. Peña wouldn't pay $24.99 for tickets to the C#-minor quartet, even if his wife's playing.")
```

For the record, the final regex looks like this. If you want to paste it into another tool, those ?: delimiters may have to go.

```
(?:[\$£€¥])?\d+(?:,\d\d\d)*\.\d+|(?:[\$£€¥])?\d+(?:,\d\d\d)*|(?:mr|ms|mrs|dr|prof|rev|rep|sen|st|sr|jr|ft|gen|adm|lt|col|etc)\.|\p{L}+'s|\p{L}+n't|[a-gjxA-GJX]#|[^\p{L}\p{Z}]|\p{L}+
```

## Case sensitivity.

Search engines are generally case insensitive and frequently include stemming. There are good reasons to do this, but they make some important but precise queries impossible.

Bookworm tokens are defined as unique by their case, but in building the database a lowercase copy of each is also stored; users can choose the collation they want by setting `words_collation` in the API call.

In some cases, this may make the process run slower. You can slightly shrink your bookworm by coercing all characters to lowercase before running.

> Stemming is not currently re-implemented, but will be soon.
