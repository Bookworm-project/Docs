# Chapter 3: Web Front Ends

The API is designed to allow a variety of possible visualizations. We've implemented a few.

## The Primary GUI
The primary GUI is at https://github.com/econpy/BookwormGUI. It runs on the highcharts library, and generates attractive line charts over time. It's easy to use, meets a significant percentage of use cases, and has some very nice design.

### Setting up a GUI instance.

To set up a Bookworm using the primary GUI, clone the git repository into a directory that's being served through your webserver. The web server application determines the name of your bookworm from the webpage you give it, so the folder should be named the same as your database. If your database is named `federalist`, for example, your page should be located at `http://myhost.org/federalist` or `http://federalist.myhost.org`.

You also need to copy the settings files created when you ran the bookworm. If your bookworm is named "mybookworm," this will be located at `/mybookworm.json` in the files directory: so from the root bookworm directory, you can set it up by running `cp files/mybookworm.json /var/www/static/options.json`.

With that done, it should run nicely.

## The D3 platform

I (Ben) have written a set of code in [D3](d3js.org) that makes a wide variety of visualizations possible, and handles the shared elements (creating dropdown selectors, fetching data through the API, making elements display information on hover and link to a search on click) transparently so new coders can just write D3 code to work with a transparent bookworm.data element.

It's uglier, though, and doesn't currently support multiple queries in the same plot.

One advantage is that since it's written as libraries that simply dump onto an existing web page, it's much easier to integrate **elements** into a wider page: for example, a treemap of a libraries contents could be deposited onto the front page without requiring any of the various interface elements.
