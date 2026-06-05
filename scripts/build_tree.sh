#!/bin/bash -l
#$ -N build_tree
#$ -cwd
#$ -l h_rt=06:00:00
#$ -pe sharedmem 12
#$ -o ../logs/$JOB_NAME.out
#$ -e ../logs/$JOB_NAME.err

set -euo pipefail

mkdir -p ../logs
mkdir -p ../phylogeny

# Activiating conda environment
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

threads="${NSLOTS:-1}"

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences ../denoise/merged_asv.qza \
  --p-n-threads "${threads}" \
  --o-alignment ../phylogeny/aligned_asv.qza \
  --o-masked-alignment ../phylogeny/masked_aligned_asv.qza \
  --o-tree ../phylogeny/unrooted_tree.qza \
  --o-rooted-tree ../phylogeny/rooted_tree.qza
