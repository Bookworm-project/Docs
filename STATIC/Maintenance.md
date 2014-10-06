# Maintenance

Bookworm stores its master lookup tables in memory rather than on disk to make lookups faster.

If there's sufficient demand, we can modify the code to allow the creation of slower but non-memory-consuming bookworms.

Old versions of Bookworm dumped out a .sql file that recreated the memory tables on restart, and added a chron job to ensure it happened.

The new version stores the code in the database itself, and can be run by invoking `python OneClick.py reloadMemory` from the Bookworm directory. (chron scripts to do this automatically will be supplied in a bit).

The new version will only rebuild a memory table if the specified table is empty, so it's safe to run it on a live instance.


