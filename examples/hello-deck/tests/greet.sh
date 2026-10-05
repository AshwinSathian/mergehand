#!/bin/sh
. src/greet.sh

test_greet_says_hello_with_the_name() {
  [ "$(hello World)" = "hello World" ] || { echo "FAIL: greet says hello with the name"; exit 1; }
}

test_greet_says_hello_with_the_name
