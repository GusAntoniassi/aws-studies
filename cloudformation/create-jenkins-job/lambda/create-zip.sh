#!/bin/bash -e

CURRENT_DIR="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -x
rm -f "$CURRENT_DIR/create-jenkins-job-lambda.zip"
(cd "$SCRIPT_DIR/package" && zip -r9 "$CURRENT_DIR/create-jenkins-job-lambda.zip" . )
(cd "$SCRIPT_DIR" && zip -g "$CURRENT_DIR/create-jenkins-job-lambda.zip" *.py)