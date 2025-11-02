#!/bin/bash

cd ../..

# custom config
DATA=/data/imagenet
TRAINER=BadClip

DATASET=imagenet
SEED=1
CFG=vit_b16_imagenet_learnable_trigger
SHOTS=16

DIR=output/imagenet_learnable/${DATASET}/shots_${SHOTS}/${TRAINER}/${CFG}/seed${SEED}
if [ -d "$DIR" ]; then
    echo "Oops! The results exist at ${DIR} (so skip this job)"
else
    python backdoor_attack.py \
    --root ${DATA} \
    --seed ${SEED} \
    --trainer ${TRAINER} \
    --dataset-config-file configs/datasets/${DATASET}.yaml \
    --config-file configs/trainers/${TRAINER}/${CFG}.yaml \
    --output-dir ${DIR} \
    DATASET.NUM_SHOTS ${SHOTS} \
    DATASET.SUBSAMPLE_CLASSES base
fi
