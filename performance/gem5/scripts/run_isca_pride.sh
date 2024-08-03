#!/bin/bash

PARA=0  # use RFMs
QSUB=0

# Create Checkpoints
#./create_checkpoints.sh

# Run Baseline
#./run_pride_baseline_experiments.sh

# This is for "rfm.perf.pride.sh"  --> AE.BASELINE.4C; RFM1.BR1.4C; RFM2.BR1.4C; RFM5.BR1.4C
# Run PrIDE (all configurations).
#for num_mitig in 1 2 5; do
#    for br in 1; do
#      ./run_pride_experiments.sh "$num_mitig" "$br" "$PARA" "$QSUB";
#    done
#done

# This is for "rfm.perf.isca.br2.sh"  --> AE.BASELINE.4C; RFM1.BR2.4C; RFM2.BR2.4C; RFM5.BR2.4C; RFM10.BR2.4C
# Run PrIDE (all configurations).
for num_mitig in 1 2 5 10; do
    for br in 2; do
      ./run_pride_experiments.sh "$num_mitig" "$br" "$PARA" "$QSUB";
    done
done

