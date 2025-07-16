#!/bin/bash
# serpent-surge-infra/terraform/bootstrap.sh

set -e

if ! command -v ansible >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y ansible
fi
