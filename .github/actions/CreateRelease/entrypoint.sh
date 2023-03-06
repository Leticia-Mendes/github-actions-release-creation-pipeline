#!/bin/bash

set -e
set -o pipefail

echo "**************************"
echo $@
pwsh /CreateRelease1.ps1 $@
echo "**************************"
