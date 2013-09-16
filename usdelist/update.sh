#!/bin/bash
RAW_FILE="usdelist.raw"
NEXT=$(wc -l < $RAW_FILE)
curl -s "http://unrealsoftware.de/users.php?raw&s=$NEXT&c=10000000" >> $RAW_FILE
