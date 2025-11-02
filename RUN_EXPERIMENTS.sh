#!/bin/bash

# BadCLIP Ablation Study: Learnable vs Fixed Trigger
# Master execution script for running all experiments

set -e  # Exit on error

echo "=========================================="
echo "BadCLIP Ablation Study"
echo "Learnable vs Fixed Trigger Comparison"
echo "=========================================="
echo ""

# Check if conda environment exists
if ! conda env list | grep -q "badclip"; then
    echo "ERROR: Conda environment 'badclip' not found!"
    echo "Please run: bash setup_environment.sh"
    exit 1
fi

# Activate conda environment
echo "Activating conda environment 'badclip'..."
eval "$(conda shell.bash hook)"
conda activate badclip

echo ""
echo "Current working directory: $(pwd)"
echo "ImageNet data path: /data/imagenet"
echo ""

# Menu for user
echo "=========================================="
echo "Select operation:"
echo "=========================================="
echo "1. Run BASELINE experiment (Learnable Trigger)"
echo "2. Run ABLATION experiment (Fixed Trigger)"
echo "3. Run BOTH experiments sequentially"
echo "4. Test Learnable Trigger (seen classes)"
echo "5. Test Learnable Trigger (unseen classes)"
echo "6. Test Fixed Trigger (seen classes)"
echo "7. Test Fixed Trigger (unseen classes)"
echo "8. Run ALL tests (4 tests total)"
echo "9. Show results comparison"
echo "0. Run everything (train + test)"
echo ""
read -p "Enter your choice [0-9]: " choice

case $choice in
    1)
        echo ""
        echo "=========================================="
        echo "Running BASELINE (Learnable Trigger)"
        echo "=========================================="
        bash scripts/badclip/imagenet_train_learnable.sh
        echo ""
        echo "Baseline training complete!"
        echo "Results saved to: output/imagenet_learnable/"
        ;;
    2)
        echo ""
        echo "=========================================="
        echo "Running ABLATION (Fixed Trigger)"
        echo "=========================================="
        bash scripts/badclip/imagenet_train_fixed.sh
        echo ""
        echo "Ablation training complete!"
        echo "Results saved to: output/imagenet_fixed/"
        ;;
    3)
        echo ""
        echo "=========================================="
        echo "Running BOTH experiments"
        echo "=========================================="
        echo ""
        echo "[1/2] Running BASELINE (Learnable Trigger)..."
        bash scripts/badclip/imagenet_train_learnable.sh
        echo ""
        echo "[2/2] Running ABLATION (Fixed Trigger)..."
        bash scripts/badclip/imagenet_train_fixed.sh
        echo ""
        echo "Both experiments complete!"
        ;;
    4)
        echo ""
        echo "=========================================="
        echo "Testing Learnable Trigger (seen classes)"
        echo "=========================================="
        bash scripts/badclip/imagenet_test_learnable_seen.sh
        ;;
    5)
        echo ""
        echo "=========================================="
        echo "Testing Learnable Trigger (unseen classes)"
        echo "=========================================="
        bash scripts/badclip/imagenet_test_learnable_unseen.sh
        ;;
    6)
        echo ""
        echo "=========================================="
        echo "Testing Fixed Trigger (seen classes)"
        echo "=========================================="
        bash scripts/badclip/imagenet_test_fixed_seen.sh
        ;;
    7)
        echo ""
        echo "=========================================="
        echo "Testing Fixed Trigger (unseen classes)"
        echo "=========================================="
        bash scripts/badclip/imagenet_test_fixed_unseen.sh
        ;;
    8)
        echo ""
        echo "=========================================="
        echo "Running ALL tests"
        echo "=========================================="
        echo ""
        echo "[1/4] Testing Learnable Trigger (seen)..."
        bash scripts/badclip/imagenet_test_learnable_seen.sh
        echo ""
        echo "[2/4] Testing Learnable Trigger (unseen)..."
        bash scripts/badclip/imagenet_test_learnable_unseen.sh
        echo ""
        echo "[3/4] Testing Fixed Trigger (seen)..."
        bash scripts/badclip/imagenet_test_fixed_seen.sh
        echo ""
        echo "[4/4] Testing Fixed Trigger (unseen)..."
        bash scripts/badclip/imagenet_test_fixed_unseen.sh
        echo ""
        echo "All tests complete!"
        ;;
    9)
        echo ""
        echo "=========================================="
        echo "Results Comparison"
        echo "=========================================="
        echo ""
        echo "To compare results, check the log.txt files in:"
        echo ""
        echo "LEARNABLE TRIGGER (Baseline):"
        echo "  Training: output/imagenet_learnable/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt"
        echo "  Test (seen): output/test_learnable_seen/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt"
        echo "  Test (unseen): output/test_learnable_unseen/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt"
        echo ""
        echo "FIXED TRIGGER (Ablation):"
        echo "  Training: output/imagenet_fixed/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt"
        echo "  Test (seen): output/test_fixed_seen/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt"
        echo "  Test (unseen): output/test_fixed_unseen/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt"
        echo ""
        echo "Key metrics to compare:"
        echo "  - ACC (Clean Accuracy): Performance on clean images"
        echo "  - ASR (Attack Success Rate): Backdoor attack success on triggered images"
        echo ""
        ;;
    0)
        echo ""
        echo "=========================================="
        echo "Running COMPLETE pipeline"
        echo "=========================================="
        echo ""
        echo "[1/6] Training BASELINE (Learnable Trigger)..."
        bash scripts/badclip/imagenet_train_learnable.sh
        echo ""
        echo "[2/6] Training ABLATION (Fixed Trigger)..."
        bash scripts/badclip/imagenet_train_fixed.sh
        echo ""
        echo "[3/6] Testing Learnable (seen)..."
        bash scripts/badclip/imagenet_test_learnable_seen.sh
        echo ""
        echo "[4/6] Testing Learnable (unseen)..."
        bash scripts/badclip/imagenet_test_learnable_unseen.sh
        echo ""
        echo "[5/6] Testing Fixed (seen)..."
        bash scripts/badclip/imagenet_test_fixed_seen.sh
        echo ""
        echo "[6/6] Testing Fixed (unseen)..."
        bash scripts/badclip/imagenet_test_fixed_unseen.sh
        echo ""
        echo "=========================================="
        echo "COMPLETE! All experiments finished."
        echo "=========================================="
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Done!"
