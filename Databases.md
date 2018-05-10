# Databases

## Log-structured storage engine

This section goes over the world's simplest database: a text file + shell
functions.

- Appends new records to the end of the file for efficient writes.
- Records are made of "key" and "value": "$1,$2".
- Reading is not efficient, as it has to go through the whole file to get to
  the last entry.

### Hash tables

Hash tables can be a way of indexing data in a log-structured storage engine.

This scheme is better suited for update-heavy databases, where each key is
frequently updated.

- To build the index, read through the DB file and store "key" + the byte
  offset at which the entry starts.
- The index is kept in-memory and reflects up-to-date entries.
- Performs compaction + merging of segments to avoid the log growing forever.
- Each merged segment has its own hash table.
- Lookups are performed sequentially, starting with the most recent segment.
- Compaction + merging can be done in a background thread. In the meantime, writes
  can still be served.
- The DB uses binary file format for efficiency: encodes the length of a string in bytes
  and has the string itself afterwards.
- Crash recovery: saves snapshots of the in-memory index to disk, so that it can
  be recovered and rebuilt in memory.
- Deleting records: appends a deletion record to the log (a tombstone). When
  merging is done, the tombstone acts as a white flag to discard the key.
- Partially written records: use checksums to avoid data corruption. If the DB
  dies halfway through writing to the log, that entry will be ignored because
  it'll have a bad checksum.
- Concurrency control: one writer thread + many read threads.
