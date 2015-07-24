# Maintenance

Bookworm stores its master lookup tables in memory rather than on disk to make lookups faster.

If there's sufficient demand, we can modify the code to allow the creation of slower but non-memory-consuming bookworms.

Old versions of Bookworm dumped out a .sql file that recreated the memory tables on restart, and added a chron job to ensure it happened.

The new version stores the code in the database itself, and can be run by invoking `./bookworm.py reload_memory` from the Bookworm directory.

There are a few potential options for this you can see by typing `./bookworm.py reload_memory --help`, that do things like not reload tables that are already populated for speed.





