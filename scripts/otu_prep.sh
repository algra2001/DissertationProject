#!/bin/bash -l

## A script to prepare trimmed batches for de-novo OTU clustering with QIIME2

# Inspiration from: https://docs.qiime2.org/2024.10/tutorials/otu-clustering/

set -euo pipefail

in_qza="$1"
# e.g. ../trimmed/05_Nov_2025.qza
out_prefix="$2"  
# e.g. ../otu_prep/05_Nov_2025.qza

# Loading QIIME2
. /etc/profile.d/modules.sh
module load anaconda
conda activate rachis-qiime2-2026.4

threads="${NSLOTS:-1}"

# Joining paired-end reads
qiime vsearch merge-pairs \
  --i-demultiplexed-seqs "${in_qza}" \
  --p-allowmergestagger \
  --p-truncqual 20 \
  --p-threads "${threads}" \
  --o-merged-sequences "${out_prefix}_joined.qza" \
  --o-unmerged-sequences "${out_prefix}_unmerged.qza"

# Pre-filter quality summary
qiime demux summarize \
  --i-data "${out_prefix}_joined.qza" \
  --o-visualization "${out_prefix}_joined.qzv"

qiime demux summarize \
  --i-data "${out_prefix}_unmerged.qza" \
  --o-visualization "${out_prefix}_unmerged.qzv"

# Quality filtering
qiime quality-filter q-score \
  --i-demux "${out_prefix}_joined.qza" \
  --o-filtered-sequences "${out_prefix}_joined_filt.qza" \
  --o-filter-stats "${out_prefix}_joined_filt_stats.qza"

# Post-filter quality summary
qiime demux summarize \
  --i-data "${out_prefix}_joined_filt.qza" \
  --o-visualization "${out_prefix}_joined_filt.qzv"

qiime metadata tabulate \
  --m-input-file "${out_prefix}_joined_filt_stats.qza" \
  --o-visualization "${out_prefix}_joined_filt_stats.qzv"

# Dereplicating
qiime vsearch dereplicate-sequences \
  --i-sequences "${out_prefix}_joined_filt.qza" \
  --o-dereplicated-table "${out_prefix}_derep_table.qza" \
  --o-dereplicated-sequences "${out_prefix}_derep_seqs.qza"

qiime feature-table summarize \
  --i-table "${out_prefix}_derep_table.qza" \
  --o-summary "${out_prefix}_derep_table.qzv" \
  --o-sample-frequencies "${out_prefix}_derep_sample_freqs.qza" \
  --o-feature-frequencies "${out_prefix}_derep_feature_freqs.qza"

# Chimera filtering
qiime vsearch uchime-denovo \
  --i-table "${out_prefix}_derep_table.qza" \
  --i-sequences "${out_prefix}_derep_seqs.qza" \
  --o-chimeras "${out_prefix}_chimeras.qza" \
  --o-nonchimeras "${out_prefix}_nonchimeras.qza" \
  --o-stats "${out_prefix}_uchime_stats.qza"

# Visualization
qiime metadata tabulate \
  --m-input-file "${out_prefix}_uchime_stats.qza" \
  --o-visualization "${out_prefix}_uchime_stats.qzv"

# Non-chimeric outputs
qiime feature-table filter-features \
  --i-table "${out_prefix}_derep_table.qza" \
  --m-metadata-file "${out_prefix}_nonchimeras.qza" \
  --o-filtered-table "${out_prefix}_nonchim_table.qza"

qiime feature-table filter-seqs \
  --i-data "${out_prefix}_derep_seqs.qza" \
  --m-metadata-file "${out_prefix}_nonchimeras.qza" \
  --o-filtered-data "${out_prefix}_nonchim_seqs.qza"
