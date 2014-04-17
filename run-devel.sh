#!/bin/bash

export __DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export __NO_LOG=1

${__DIR}/run.sh $@