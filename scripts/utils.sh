#!/bin/bash

cd_error() {
  echo "Error on file $2, line #$3"
  echo "Script error detected, current directory ($1) seems not exist any more, exiting..."
  sudo -k
  exit 1
}
