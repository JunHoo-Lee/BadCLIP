# BadCLIP Ablation Study - Quick Start Guide

## TL;DR - Copy and Paste These Commands

### 1. Setup Environment (One-time)
```bash
cd /data/junhoo/BadCLIP
bash setup_environment.sh
```

### 2. PARALLEL Execution (Recommended - Uses Multiple GPUs!)
```bash
cd /data/junhoo/BadCLIP
conda activate badclip

# Train both experiments in parallel (GPU 0-1)
bash scripts/badclip/imagenet_train_parallel.sh

# Test all 4 in parallel (GPU 0-3)
bash scripts/badclip/imagenet_test_parallel.sh
```

⚡ **2-4x faster than sequential!** See [RUN_PARALLEL.md](RUN_PARALLEL.md) for details.

### 3. Or Run Complete Pipeline (Interactive Menu)
```bash
cd /data/junhoo/BadCLIP
conda activate badclip
bash RUN_EXPERIMENTS.sh
# Press: 0 (to run everything)
```

### 4. Or Run Step-by-Step (Sequential)
```bash
cd /data/junhoo/BadCLIP
conda activate badclip

# Train baseline (learnable trigger)
bash scripts/badclip/imagenet_train_learnable.sh

# Train ablation (fixed trigger)
bash scripts/badclip/imagenet_train_fixed.sh

# Test learnable (seen & unseen)
bash scripts/badclip/imagenet_test_learnable_seen.sh
bash scripts/badclip/imagenet_test_learnable_unseen.sh

# Test fixed (seen & unseen)
bash scripts/badclip/imagenet_test_fixed_seen.sh
bash scripts/badclip/imagenet_test_fixed_unseen.sh
```

### 4. Check Results
```bash
# View training logs
cat output/imagenet_learnable/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt
cat output/imagenet_fixed/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt

# Extract metrics
grep -i "accuracy" output/*/imagenet/shots_16/BadClip/*/seed1/log.txt
grep -i "backdoor" output/*/imagenet/shots_16/BadClip/*/seed1/log.txt
```

## What Gets Executed

### Baseline (Learnable Trigger)
- Config: `vit_b16_imagenet_learnable_trigger.yaml`
- Trigger: Optimized during training
- Warm-up: 3 epochs of trigger initialization
- Output: `output/imagenet_learnable/`

### Ablation (Fixed Trigger)
- Config: `vit_b16_imagenet_fixed_trigger.yaml`
- Trigger: Fixed 4x4 white patch at (220,220)
- Warm-up: None (skipped)
- Output: `output/imagenet_fixed/`

## Expected Runtime

- Environment setup: ~10-15 minutes
- Training (per experiment): ~2-4 hours (depends on GPU)
- Testing (per test): ~30-60 minutes

## Key Metrics

Look for these in `log.txt`:
- **accuracy**: Clean accuracy (higher = better)
- **backdoor accuracy** or **ASR**: Attack success rate (higher = stronger attack)

## Files Created

```
/data/junhoo/BadCLIP/
├── setup_environment.sh                          # Environment setup
├── RUN_EXPERIMENTS.sh                            # Master script
├── ABLATION_STUDY_INSTRUCTIONS.md               # Detailed guide
├── QUICK_START.md                                # This file
├── trainers/
│   └── badclip.py                                # Modified trainer
├── configs/trainers/BadClip/
│   ├── vit_b16_imagenet_learnable_trigger.yaml  # Learnable config
│   └── vit_b16_imagenet_fixed_trigger.yaml      # Fixed config
└── scripts/badclip/
    ├── imagenet_train_learnable.sh
    ├── imagenet_train_fixed.sh
    ├── imagenet_test_learnable_seen.sh
    ├── imagenet_test_learnable_unseen.sh
    ├── imagenet_test_fixed_seen.sh
    └── imagenet_test_fixed_unseen.sh
```

## Troubleshooting

**"No module named backdoor_attack" error?**

- Fixed! All scripts now use `python backdoor_attack.py` instead of `python -m backdoor_attack`
- Make sure you're running from the correct directory: `/data/junhoo/BadCLIP`

**CUDA not available?**
```bash
python -c "import torch; print(torch.cuda.is_available())"
nvidia-smi
```

**Conda environment issues?**
```bash
conda env remove -n badclip
bash setup_environment.sh
```

**ImageNet not found?**
```bash
ls /data/imagenet  # Should show train/ and val/ directories
```

## Next Steps

1. Run experiments
2. Compare results in log files
3. Analyze ACC vs ASR trade-offs
4. Check transferability to unseen classes

See [ABLATION_STUDY_INSTRUCTIONS.md](ABLATION_STUDY_INSTRUCTIONS.md) for detailed documentation.
