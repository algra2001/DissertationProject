#!/bin/bash -l
#$ -cwd
#$ -t 1-13
#$ -N qiime2_trim_primers
#$ -l h_rt=24:00:00
#$ -pe sharedmem 12
#$ -o ../logs/$JOB_NAME.$TASK_ID.out
#$ -e ../logs/$JOB_NAME.$TASK_ID.err

set -euo pipefail

file_base=$(sed -n "${SGE_TASK_ID}p" filestoprocess.txt)

infile="../visualization/${file_base}.qza"
outfile="../trimmed/${file_base}_trimmed.qza"

./trim_primers.sh "${infile}" "${outfile}"
