#!/usr/bin/env bash

set -euo pipefail

set

[[ -z "${AWS_SECRET_ACCESS_KEY:-}" ]] && echo "[ERROR] - AWS_SECRET_ACCESS_KEY must be set in Doppler!"
[[ -z "${AWS_ACCESS_KEY:-}" ]] && echo "[ERROR] - AWS_ACCESS_KEY must be set in Doppler!"

aws configure set aws_access_key_id ${AWS_ACCESS_KEY}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
