# Required Files

To build a bookworm, you need three files:

1. `input.txt`: a single file containing your texts (see the section for alternates if that's impractical;
2. `jsoncatalog.txt`: metadata about each text;
3. `field_descriptions.json`: metadata about your metadata, such as which fields are dates and which are categorical.

The result of this chapter describes the format for these three input files.

These can be stored in one of two locations:

## External format

If you want to clone a bookworm as part of a larger installation, you
can leave the files in a root directory. This is frequently cleaner,
and is the recommended format. In this case, your file structure will look like.

```
your_directory/
 -- jsoncatalog.txt
 -- input.txt
 -- field_descriptions.json
```

To build the Bookworm, follow the instructions.

## Internal Format

This is a legacy format. There is no reason to use it. Relative to the root directory (which will be called `BookwormDB` if you clone this repo directly), they are all in a subdirectory called `files`. When you've built them all, it will look like this:

```
BookwormDB/
 -- files/
  | -- texts/
  |  | raw  <--- (alternate method: contains texts files or hierarchical folders of text files)
  |  | input.txt <----- (preferred method: a single file with all texts, preceded by their id.)
  | -- metadata/
  |  | -- jsoncatalog.txt
  |  | -- field_descriptions.json

```

There is also a highly deprecated format, occasionally suggested by
some old documentation and installations, that recommends a folder
called `texts` inside files. Really, really, do not use this format. 
