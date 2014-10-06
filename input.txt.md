# input.txt

Previous versions of bookworm required as input a single file for each document stored. That was tremendously inefficient, so later versions are geared around formats that allow the use of one or a few input files.

### Character encoding

The input should be in UTF-8. (ASCII is a valid subset of UTF-8, and therefore acceptable). Bookworm attempts to warn when skipping words in invalid encodings (many Latin-1 characters, for example), but we cannot guarantee that every strange character will produce the correct result.

## The easy route: a single file

The basic file format for input.txt is a single string that serves as an identifier for the text (keyed to the `filename` element in [jsoncatalog.txt](), followed by the full text of the document, **with all newlines and carriage returns replaced by spaces**.

```
TaleOfTwoCities   It was the best of times, It was the worst of times…
```

## More complicated: using a pipe

If you have, for example, several different smaller files in that format you want Bookworm to read in all at once, you could run

```{sh}
mkfifo texts/input.txt
cat mytextfolder.* > texts/input.txt &
make database bookwormName=OL
```

## Most flexible: specify a path.

They said you could have a Model T in any color you liked, as long as it was black. Bookworm is happy to work with texts of any format, as long as it gets them in the two-column format above.

What does this mean? If you're working with a set of gzipped tarballs, for instance, you don't have to actually decompress them first: you can just script a program that writes to `stdout` in the above format, and pass that program to the makefile. So if you wrote a script that printed out elements on the fly and put it into 'scripts' (the recommended, but not necessary, place) you could run
```{sh}
make bookwormName=OL textStream=scripts/unzipTarball.sh
```

and the bookworm would successfully build without any file named `input.txt` at all.

The lack of an `input.txt` may be a problem for certain extensions.

## Preprocessing

Lots of texts are messy: they have Google bookplates, hyphenated words broken at newlines, or scraps of HTML. You can leave these in the Bookworm and suffer through: or you can scrip them around.
