#!/bin/bash

export __DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd ${__DIR}/src/
thin stop
popd