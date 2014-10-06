# Meta-Bookworm

Bookworm currently has a 16 million document limit. This corresponds to the maximum size of an unsigned, 3-byte integer in MySQL. It would be possible to simply change that to a 4-byte integer; but around 8 million texts, Bookworm queries start to get a bit slow a lot of the time.

The reason has to do with the bottleneck on a query.
There are two different constraints on query time:

* The word lookup queries (time increases as O(log(n))).
* The merges with the catalog (time increases as O(n)).

Queries on smallish (under 500,000 documents) bookworms take trivial amounts of time, perhaps because they're throttled by the first element; on large bookworms, the scaling seems to be dominated by the linear scaling.

One fascinating, if slightly problematic, solution would be to implement a **meta-bookworm**: that is, an implementation of the Bookworm API that runs not on a database, but that dispatches to a number of different API instances itself.

So given a "word per million" query grouped by year, it would "know" 10 servers associated with that database; it would dispatch wordcount and totalWords queries to each of them; and as the results came back in, it would merge them together into a single result set. (I imagine this being written in python using pandas to optimize merges, but other options are possible).

**Creation**

This would be created by dispatching, at creation time, the individual documents randomly across a number of different servers. (I think random distribution would be the fastest for queries). Each server would then have a functioning MySQL (or Solr, or whatever) Bookworm.

Creation times would be faster significantly than on the current Bookworms; most of the build scales as O(n), and index creation is O(n*log(n)).

**Running on existing Bookworms**

It could also be deploted across existing sets of Bookworms: if, for example, multiple institutions included newspapers with similar metadata, someone could implement a meta-bookworm that returned intersecting fields from the various bookworms. (In fact, the meta-bookworm spec could be defined to look for intersections in a `return_available_fields` call). Then, you could have a single GUI plotting results from multiple different collections, returning links to different elements.


**Problems**

At smaller bookworms, this might be slower than a single bookworm, particularly if there are O(log(n)) dynamics at play.

Connection and merge overhead times make me suspect this is probably only sensible with more than 3 or 4 servers; just 2 would be silly.

If one server is down, the entire Bookworm will time out. It could return results on partial implementations, or it could be defined to have multiple copies of each server, and to use whichever returns first.

**And the central farm**

For a central distributed installation at Chicago, say, this might be a way to distribute load evenly across a number of different servers. Particularly when spikes in use will be different by different bookworms, this would nicely smooth out use.
