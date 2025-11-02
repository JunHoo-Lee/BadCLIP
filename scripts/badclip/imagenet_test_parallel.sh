#!/bin/bash

# Run all 4 test experiments in PARALLEL using different GPUs
# GPU 0: Learnable trigger - seen classes
# GPU 1: Learnable trigger - unseen classes
# GPU 2: Fixed trigger - seen classes
# GPU 3: Fixed trigger - unseen classes

echo "=========================================="
echo "Running PARALLEL Testing (4 tests)"
echo "GPU 1: Learnable - Seen"
echo "GPU 2: Learnable - Unseen"
echo "GPU 3: Fixed - Seen"
echo "GPU 4: Fixed - Unseen"
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
LOADEP=10

# Test 1: Learnable trigger - seen classes (GPU 0)
CFG_LEARNABLE=vit_b16_imagenet_learnable_trigger
COMMON_DIR_LEARNABLE=${DATASET}/shots_${SHOTS}/${TRAINER}/${CFG_LEARNABLE}/seed${SEED}
MODEL_DIR_LEARNABLE=output/imagenet_learnable/${COMMON_DIR_LEARNABLE}
DIR_LEARNABLE_SEEN=output/test_learnable_seen/${COMMON_DIR_LEARNABLE}

if [ ! -d "$DIR_LEARNABLE_SEEN" ]; then
    echo "Starting Test 1: Learnable - Seen (GPU 1)..."
    CUDA_VISIBLE_DEVICES=1 python backdoor_attack.py \
        --root ${DATA} \
        --seed ${SEED} \
        --trainer ${TRAINER} \
        --dataset-config-file configs/datasets/${DATASET}.yaml \
        --config-file configs/trainers/${TRAINER}/${CFG_LEARNABLE}.yaml \
        --output-dir ${DIR_LEARNABLE_SEEN} \
        --model-dir ${MODEL_DIR_LEARNABLE} \
        --load-epoch ${LOADEP} \
        --eval-only \
        DATASET.NUM_SHOTS ${SHOTS} \
        DATASET.SUBSAMPLE_CLASSES base \
        > ${DIR_LEARNABLE_SEEN}_test.log 2>&1 &
    PID1=$!
fi

# Test 2: Learnable trigger - unseen classes (GPU 1)
DIR_LEARNABLE_UNSEEN=output/test_learnable_unseen/${COMMON_DIR_LEARNABLE}

if [ ! -d "$DIR_LEARNABLE_UNSEEN" ]; then
    echo "Starting Test 2: Learnable - Unseen (GPU 2)..."
    CUDA_VISIBLE_DEVICES=2 python backdoor_attack.py \
        --root ${DATA} \
        --seed ${SEED} \
        --trainer ${TRAINER} \
        --dataset-config-file configs/datasets/${DATASET}.yaml \
        --config-file configs/trainers/${TRAINER}/${CFG_LEARNABLE}.yaml \
        --output-dir ${DIR_LEARNABLE_UNSEEN} \
        --model-dir ${MODEL_DIR_LEARNABLE} \
        --load-epoch ${LOADEP} \
        --eval-only \
        DATASET.NUM_SHOTS ${SHOTS} \
        DATASET.SUBSAMPLE_CLASSES new \
        > ${DIR_LEARNABLE_UNSEEN}_test.log 2>&1 &
    PID2=$!
fi

# Test 3: Fixed trigger - seen classes (GPU 2)
CFG_FIXED=vit_b16_imagenet_fixed_trigger
COMMON_DIR_FIXED=${DATASET}/shots_${SHOTS}/${TRAINER}/${CFG_FIXED}/seed${SEED}
MODEL_DIR_FIXED=output/imagenet_fixed/${COMMON_DIR_FIXED}
DIR_FIXED_SEEN=output/test_fixed_seen/${COMMON_DIR_FIXED}

if [ ! -d "$DIR_FIXED_SEEN" ]; then
    echo "Starting Test 3: Fixed - Seen (GPU 3)..."
    CUDA_VISIBLE_DEVICES=3 python backdoor_attack.py \
        --root ${DATA} \
        --seed ${SEED} \
        --trainer ${TRAINER} \
        --dataset-config-file configs/datasets/${DATASET}.yaml \
        --config-file configs/trainers/${TRAINER}/${CFG_FIXED}.yaml \
        --output-dir ${DIR_FIXED_SEEN} \
        --model-dir ${MODEL_DIR_FIXED} \
        --load-epoch ${LOADEP} \
        --eval-only \
        DATASET.NUM_SHOTS ${SHOTS} \
        DATASET.SUBSAMPLE_CLASSES base \
        > ${DIR_FIXED_SEEN}_test.log 2>&1 &
    PID3=$!
fi

# Test 4: Fixed trigger - unseen classes (GPU 3)
DIR_FIXED_UNSEEN=output/test_fixed_unseen/${COMMON_DIR_FIXED}

if [ ! -d "$DIR_FIXED_UNSEEN" ]; then
    echo "Starting Test 4: Fixed - Unseen (GPU 4)..."
    CUDA_VISIBLE_DEVICES=4 python backdoor_attack.py \
        --root ${DATA} \
        --seed ${SEED} \
        --trainer ${TRAINER} \
        --dataset-config-file configs/datasets/${DATASET}.yaml \
        --config-file configs/trainers/${TRAINER}/${CFG_FIXED}.yaml \
        --output-dir ${DIR_FIXED_UNSEEN} \
        --model-dir ${MODEL_DIR_FIXED} \
        --load-epoch ${LOADEP} \
        --eval-only \
        DATASET.NUM_SHOTS ${SHOTS} \
        DATASET.SUBSAMPLE_CLASSES new \
        > ${DIR_FIXED_UNSEEN}_test.log 2>&1 &
    PID4=$!
fi

echo ""
echo "All test jobs started! Waiting for completion..."
echo ""

# Wait for all background jobs
wait

echo ""
echo "=========================================="
echo "All testing jobs completed!"
echo "=========================================="
