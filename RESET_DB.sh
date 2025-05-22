#!/bin/bash

# Define target subdirectories
LOG_DIRS=(da dakxi-da eoi rt sm sp)
DB_DIR="./data/db"

# Clear log subdirectories
for dir in "${LOG_DIRS[@]}"; do
  path="./data/logs/$dir"
  if [ -d "$path" ]; then
    echo "Cleaning $path"
    rm -rf "$path"/*
  else
    echo "Directory $path does not exist"
  fi
done

# Clear database directory
if [ -d "$DB_DIR" ]; then
  echo "Cleaning $DB_DIR"
  rm -rf "$DB_DIR"/*
else
  echo "Directory $DB_DIR does not exist"
fi

echo "Cleanup complete."