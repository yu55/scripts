#!/bin/bash

logger "Starting cleaning up databases...";

sqlite3 /var/local/am2301-db.sl3 "VACUUM;";
sqlite3 /var/local/am2301-db.sl3 "REINDEX;";

sqlite3 /var/local/auriol-db.sl3 "VACUUM;";
sqlite3 /var/local/auriol-db.sl3 "REINDEX;";

sqlite3 /var/local/relay-by-temp-db.sl3 "VACUUM;";
sqlite3 /var/local/relay-by-temp-db.sl3 "REINDEX;";

sqlite3 /var/local/tigra-temp-db.sl3 "VACUUM;";
sqlite3 /var/local/tigra-temp-db.sl3 "REINDEX;";

logger "Ended cleaning up databases";

