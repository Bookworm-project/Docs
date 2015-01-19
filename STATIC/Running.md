# Running the script

The central creation for a Bookworm is handled by a Makefile.

The easiest way to create a Bookworm is simply to make sure you have stored the files as described above at:
1. `files/texts/input.txt` (or a number of files at `files/texts/raw`
2. `files/metadata/jsoncatalog.txt`
3. `files/metadata/field_descriptions.json`

Once this is done, simply run `make`. The first time you do this, it will prompt you for the name of the Bookworm, username, and password to build; then it will run through all the data and build the Bookworm in place.

The bookworm is the name of the database (and the website): it can't include spaces.

The username and password **are not your personal username and password**. They are, instead, a default username and password that the web site will use. This is for an extra layer of security; all Bookworm queries are performed by a user with no privileges to change the database. In general, the right place to store this is at your **system-level** `my.cnf` file. (It may be located somewhere like `/etc/my.cnf` on OS X, or `/etc/mysql/my.cnf` on Ubuntu.) These must be the same as the username and password that Apache will use when executing a CGI script.

## Understanding the Workflow.

All jobs are dispatched through the Makefile--if you can read through the dependency chain to see how it's put together, you'll understand all the elements.

For reference, the general workflow of the Makefile is the following:

1. Build the directory structure in `files/texts/`.
2. Derive `files/metadata/field_descriptions_derived.json` from `files/metadata/field_descriptions.json`.
3. Derive `files/metadata/jsoncatalog_derived.txt` from `files/metadata/jsoncatalog.txt`.
4. Create metadata catalog files in `files/metadata/`.
5. Create, if not pre-defined, a file at `files/wordlist/wordlist.txt` that defines the tokens that will be counted (the million most common tokens).
6. Encode unigrams and bigrams from the binaries into `files/encoded`.
7. Load wordcounts into MySQL database.
8. Load metadata into MySQL database.
9. Create temporary MySQL table and .json file that will be used by the web app.
10. Create API settings for the web app.

At any point, you can backtrack part of the way by clearing out files from `files/targets`.
