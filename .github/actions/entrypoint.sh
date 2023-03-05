#!/bin/bash

set -e
set -o pipefail

echo "**************************"
echo $@
pwsh /CreationRelease.ps1 $@
echo "**************************"
