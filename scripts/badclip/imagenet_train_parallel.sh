#!/bin/bash

# Run both training experiments in PARALLEL using different GPUs
# GPU 0: Learnable trigger
# GPU 1: Fixed trigger

echo "=========================================="
echo "Running PARALLEL Training"
echo "GPU 1: Learnable Trigger (Baseline)"
echo "GPU 2: Fixed Trigger (Ablation)"
echo "=========================================="
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Go to the project root
cd "${SCRIPT_DIR}/../.."

# Configuration
DATA=/data/imagenet
TRAINER=BadClip
DATASET=imagenet
SEED=1
SHOTS=16

# Learnable trigger config
CFG_LEARNABLE=vit_b16_imagenet_learnable_trigger
DIR_LEARNABLE=output/imagenet_learnable/${DATASET}/shots_${SHOTS}/${TRAINER}/${CFG_LEARNABLE}/seed${SEED}

# Fixed trigger config
CFG_FIXED=vit_b16_imagenet_fixed_trigger
DIR_FIXED=output/imagenet_fixed/${DATASET}/shots_${SHOTS}/${TRAINER}/${CFG_FIXED}/seed${SEED}

# Run learnable trigger on GPU 0 in background
if [ -d "$DIR_LEARNABLE" ]; then
    echo "Learnable trigger results already exist at ${DIR_LEARNABLE}"
else
    echo "Starting learnable trigger training on GPU 0..."
    CUDA_VISIBLE_DEVICES=0 python backdoor_attack.py \
        --root ${DATA} \
        --seed ${SEED} \
        --trainer ${TRAINER} \
        --dataset-config-file configs/datasets/${DATASET}.yaml \
        --config-file configs/trainers/${TRAINER}/${CFG_LEARNABLE}.yaml \
        --output-dir ${DIR_LEARNABLE} \
        DATASET.NUM_SHOTS ${SHOTS} \
        DATASET.SUBSAMPLE_CLASSES base \
        > ${DIR_LEARNABLE}_training.log 2>&1 &

    PID_LEARNABLE=$!
    echo "Learnable trigger training started (PID: ${PID_LEARNABLE})"
fi

# Run fixed trigger on GPU 1 in background
if [ -d "$DIR_FIXED" ]; then
    echo "Fixed trigger results already exist at ${DIR_FIXED}"
else
    echo "Starting fixed trigger training on GPU 1..."
    CUDA_VISIBLE_DEVICES=1 python backdoor_attack.py \
        --root ${DATA} \
        --seed ${SEED} \
        --trainer ${TRAINER} \
        --dataset-config-file configs/datasets/${DATASET}.yaml \
        --config-file configs/trainers/${TRAINER}/${CFG_FIXED}.yaml \
        --output-dir ${DIR_FIXED} \
        DATASET.NUM_SHOTS ${SHOTS} \
        DATASET.SUBSAMPLE_CLASSES base \
        > ${DIR_FIXED}_training.log 2>&1 &

    PID_FIXED=$!
    echo "Fixed trigger training started (PID: ${PID_FIXED})"
fi

# Wait for both to complete
echo ""
echo "Waiting for both training jobs to complete..."
echo "Monitor progress with:"
if [ ! -z "${PID_LEARNABLE}" ]; then
    echo "  tail -f ${DIR_LEARNABLE}_training.log"
fi
if [ ! -z "${PID_FIXED}" ]; then
    echo "  tail -f ${DIR_FIXED}_training.log"
fi
echo ""

# Wait for all background jobs
wait

echo ""
echo "=========================================="
echo "Both training jobs completed!"
echo "=========================================="
