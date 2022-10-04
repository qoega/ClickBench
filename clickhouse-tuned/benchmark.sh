#!/bin/bash

# Install

#curl https://clickhouse.com/ | sh
#sudo DEBIAN_FRONTEND=noninteractive ./clickhouse install

# Optional: if you want to use higher compression:
echo "
compression:
    case:
        method: zstd
" | sudo tee /etc/clickhouse-server/config.d/compression.yaml

echo "uncompressed_cache_size: " `cat /proc/meminfo | grep "MemTotal" | awk '{print $2 * 1024 * 0.25}'` | sudo tee /etc/clickhouse-server/config.d/uncompressed_cache.yaml

sudo clickhouse restart

# Load the data
clickhouse-client --query "DROP TABLE IF EXISTS hits"
clickhouse-client < create.sql

#wget --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
#gzip -d hits.tsv.gz

clickhouse-client --time --query "INSERT INTO hits FORMAT TSV" < hits.tsv
clickhouse-client --time --query "OPTIMIZE TABLE hits FINAL"

# Run the queries

./run.sh

clickhouse-client --query "SELECT total_bytes FROM system.tables WHERE name = 'hits' AND database = 'default'"
