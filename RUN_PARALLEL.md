# BadCLIP - Parallel Execution Guide (8 GPUs)

Since you have **8 GPUs**, you can run experiments in parallel to save time!

## Quick Commands

### Option 1: Train Both Experiments in Parallel (Recommended)
```bash
cd /data/junhoo/BadCLIP
conda activate badclip
bash scripts/badclip/imagenet_train_parallel.sh
```

This runs:
- **GPU 0**: Learnable trigger (baseline)
- **GPU 1**: Fixed trigger (ablation)

Both experiments run simultaneously! 🚀

### Option 2: Test All 4 Tests in Parallel
```bash
cd /data/junhoo/BadCLIP
conda activate badclip
bash scripts/badclip/imagenet_test_parallel.sh
```

This runs all 4 tests at once:
- **GPU 0**: Learnable - Seen classes
- **GPU 1**: Learnable - Unseen classes
- **GPU 2**: Fixed - Seen classes
- **GPU 3**: Fixed - Unseen classes

### Option 3: Full Pipeline (Train + Test in Parallel)
```bash
cd /data/junhoo/BadCLIP
conda activate badclip

# Step 1: Train both in parallel (uses GPU 0-1)
bash scripts/badclip/imagenet_train_parallel.sh

# Step 2: Test all 4 in parallel (uses GPU 0-3)
bash scripts/badclip/imagenet_test_parallel.sh
```

## Monitoring Progress

While training/testing runs in the background, monitor with:

```bash
# Watch GPU usage
watch -n 1 nvidia-smi

# View training logs (learnable)
tail -f output/imagenet_learnable_training.log

# View training logs (fixed)
tail -f output/imagenet_fixed_training.log
```

## Time Savings

| Method | Time | GPUs Used |
|--------|------|-----------|
| Sequential (original) | ~8-12 hours | 1 GPU |
| **Parallel Training** | ~4-6 hours | 2 GPUs |
| **Parallel Testing** | ~30-60 min | 4 GPUs |
| **Total Parallel** | ~5-7 hours | 2-4 GPUs |

**Time saved: ~40-50%!**

## Log Files

Parallel execution creates separate log files:

```
/data/junhoo/BadCLIP/
├── output/imagenet_learnable_training.log    # Learnable training log
├── output/imagenet_fixed_training.log         # Fixed training log
├── output/test_learnable_seen_test.log        # Test logs...
└── ...
```

## Manual Parallel Execution (More Control)

If you want full control over GPU assignment:

### Train on Specific GPUs
```bash
cd /data/junhoo/BadCLIP

# Train learnable on GPU 0 in background
CUDA_VISIBLE_DEVICES=0 bash scripts/badclip/imagenet_train_learnable.sh &

# Train fixed on GPU 1 in background
CUDA_VISIBLE_DEVICES=1 bash scripts/badclip/imagenet_train_fixed.sh &

# Wait for both to finish
wait
```

### Test on Specific GPUs
```bash
# Run all 4 tests on different GPUs
CUDA_VISIBLE_DEVICES=0 bash scripts/badclip/imagenet_test_learnable_seen.sh &
CUDA_VISIBLE_DEVICES=1 bash scripts/badclip/imagenet_test_learnable_unseen.sh &
CUDA_VISIBLE_DEVICES=2 bash scripts/badclip/imagenet_test_fixed_seen.sh &
CUDA_VISIBLE_DEVICES=3 bash scripts/badclip/imagenet_test_fixed_unseen.sh &

# Wait for all to finish
wait
```

## Troubleshooting

**Out of memory errors?**
- Reduce batch size in config files
- Use fewer GPUs in parallel

**Jobs not running in background?**
```bash
# Check running jobs
jobs

# Check GPU usage
nvidia-smi

# Check if processes are running
ps aux | grep backdoor_attack
```

**Kill parallel jobs if needed:**
```bash
# Kill all Python backdoor_attack processes
pkill -f backdoor_attack.py
```

## Advantages of Parallel Execution

✅ **2x faster training** (both experiments run simultaneously)
✅ **4x faster testing** (all tests run simultaneously)
✅ **Better GPU utilization** (uses 2-4 of your 8 GPUs)
✅ **Separate logs** for easier debugging
✅ **Same results** as sequential execution

## What's Next?

After running parallel experiments, compare results:

```bash
# Quick comparison
bash RUN_EXPERIMENTS.sh
# Select option 9 (Show results comparison)
```

Or manually:
```bash
grep -i "accuracy" output/*/imagenet/shots_16/BadClip/*/seed1/log.txt
```
