#!/bin/bash

cd ../..

# custom config
DATA=/data/imagenet
TRAINER=BadClip

DATASET=imagenet
SEED=1
CFG=vit_b16_imagenet_fixed_trigger
SHOTS=16
LOADEP=10
SUB=base  # Test on seen classes

COMMON_DIR=${DATASET}/shots_${SHOTS}/${TRAINER}/${CFG}/seed${SEED}
MODEL_DIR=output/imagenet_fixed/${COMMON_DIR}
DIR=output/test_fixed_seen/${COMMON_DIR}
if [ -d "$DIR" ]; then
    echo "Oops! The results exist at ${DIR} (so skip this job)"
else
    python -m backdoor_attack \
    --root ${DATA} \
    --seed ${SEED} \
    --trainer ${TRAINER} \
    --dataset-config-file configs/datasets/${DATASET}.yaml \
    --config-file configs/trainers/${TRAINER}/${CFG}.yaml \
    --output-dir ${DIR} \
    --model-dir ${MODEL_DIR} \
    --load-epoch ${LOADEP} \
    --eval-only \
    DATASET.NUM_SHOTS ${SHOTS} \
    DATASET.SUBSAMPLE_CLASSES ${SUB}
fi
