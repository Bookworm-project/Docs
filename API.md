# The Bookworm API

The Bookworm API acts as an interchange format for requesting data about large collections of texts.

The orthodox implementation at the time of writing is [my BookwormAPI repository](https://www.github.com/Bookworm-project/BookwormAPI), written in Python and connecting to the MySQL backend.

One of the major advantages of the API, however, is that it can be implemented on top of other systems (in whole or in part); so that bookcounts queries can easily be run through Solr, for example.

You can clone the repository directly into your webserver's `/cgi-bin` directory, or just download the scripts if there are other cgi-scripts you don't want to disturb. Once it's cloned, you should be able to query the database by hitting, for example, `http://myhost.org/cgi-bin/dbbindings.py?queryTerms={"database":"YOURDBNAME","method":"returnPossibleFields"}`

Your local web installations will rely on this API working to make queries.


### Troubleshooting

You can submit issues ot the github page.

#### Is your bookworm code broken?

To tell if your API is broken, first try the command-line interface to the API using `bookworm query '{"format":"return_tsv","database":"$your_database","counttype":"counttype"}'` 

Also try running the federalist test suite by running some of the test scripts.

#### Is your Apache configuration working?

This script uses python to connect to MySQL through Apache, so there are many possible points of failure. Check `/var/log/apache2/error.log` or elsewhere.

If that works but the cgi-bin 

1. Are all python modules loaded?
2. Are .py scripts in `/cgi-bin` treated as executable?
3. Does the version of python in the shebang have access to the required modules, including numpy?
    * If you're running it under OS X and Homebrew, you may need to change the opening shebang to `#!/usr/local/bin/python` to make use of all necessary modules.
4. Is python able to connect to a running MySQL instance using the specified login files?

### Running the API and the MySQL backend on separate servers.

This is possible through manipulating the "known_hosts" file.
