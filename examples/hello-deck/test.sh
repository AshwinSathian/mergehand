#!/bin/sh
# The check command: every test must pass.
set -e
for t in tests/*.sh; do sh "$t"; done
