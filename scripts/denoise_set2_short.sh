#!/bin/bash -l

## Script for denoising paired-end sequences

set -euo pipefail

# QIIME2 artifact from the CLI
# e.g., 05_Nov_2025
infile="$1"
prefix="$2"

# Loading QIIME2
. /etc/profile.d/modules.sh

module load anaconda
conda activate rachis-qiime2-2026.4

# Number of threads from the batch script.

threads="${NSLOTS:-1}"

# Denoising, change parameteres
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs "${infile}" \
  --p-trim-left-f 0 \
  --p-trunc-len-f 230 \
  --p-trim-left-r 0 \
  --p-trunc-len-r 230 \
  --p-n-threads "${threads}" \
  --o-representative-sequences "${prefix}_asv.qza" \
  --o-table "${prefix}_asv_table.qza" \
  --o-denoising-stats "${prefix}_denoising_stats.qza" \
  --o-base-transition-stats "${prefix}_base_transition_stats.qza"
