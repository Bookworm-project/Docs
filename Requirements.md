# Required Files

To build a bookworm, files are required in three places. Relative to the root directory (which will be called `Presidio` if you clone this repo directly), they are all in a subdirectory called `files`. When you've built them all, it will look like this:

```
Presidio/
 -- files/
  | -- texts/
  |  | raw  <--- (alternate method: contains texts files or hierarchical folders of text files)
  |  | input.txt <----- (preferred method: a single file with all texts, preceded by their id.)
  | -- metadata/
  |  | -- jsoncatalog.txt
  |  | -- field_descriptions.json

```

The result of this chapter describes the format for these three input files.
