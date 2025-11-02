# BadCLIP Ablation Study: Learnable vs Fixed Trigger

## Overview

This setup allows you to run an ablation study comparing:
- **BASELINE**: BadCLIP with learnable trigger (original implementation)
- **ABLATION**: BadCLIP with fixed trigger (only prompt learning)

## What Was Modified

### 1. Code Changes ([trainers/badclip.py](trainers/badclip.py))

Modified the `Trigger` class and `BadClip` trainer to support both learnable and fixed triggers:

- **Trigger class** (lines 169-225):
  - Added `learnable` parameter (read from `cfg.BACKDOOR.LEARNABLE`)
  - When `learnable=True`: Uses `nn.Parameter` (original behavior)
  - When `learnable=False`: Creates 4x4 white patch at position (220,220) using `register_buffer`

- **BadClip.build_model()** (lines 305-314):
  - Only creates trigger optimizer if `trigger.learnable=True`
  - Skips optimizer creation for fixed trigger

- **BadClip.before_train()** (lines 402-408):
  - Skips trigger warm-up phase if trigger is fixed

- **BadClip.forward_backward()** (lines 441-463):
  - Only calls `trigger_optim.step()` if trigger is learnable

### 2. Configuration Files

Created two trainer configs in `configs/trainers/BadClip/`:

1. **vit_b16_imagenet_learnable_trigger.yaml**
   - `BACKDOOR.LEARNABLE: True`
   - `BACKDOOR.INIT.EXEC: True` (trigger warm-up enabled)
   - Uses learnable trigger (baseline)

2. **vit_b16_imagenet_fixed_trigger.yaml**
   - `BACKDOOR.LEARNABLE: False`
   - `BACKDOOR.INIT.EXEC: False` (no trigger warm-up needed)
   - Uses fixed 4x4 white patch (ablation)

### 3. Training Scripts (`scripts/badclip/`)

- `imagenet_train_learnable.sh` - Train with learnable trigger
- `imagenet_train_fixed.sh` - Train with fixed trigger

Output directories:
- Learnable: `output/imagenet_learnable/`
- Fixed: `output/imagenet_fixed/`

### 4. Testing Scripts (`scripts/badclip/`)

- `imagenet_test_learnable_seen.sh` - Test learnable on seen classes
- `imagenet_test_learnable_unseen.sh` - Test learnable on unseen classes
- `imagenet_test_fixed_seen.sh` - Test fixed on seen classes
- `imagenet_test_fixed_unseen.sh` - Test fixed on unseen classes

## Quick Start

### Step 1: Environment Setup

```bash
cd /data/junhoo/BadCLIP
bash setup_environment.sh
```

This will:
1. Create conda environment `badclip` with Python 3.8
2. Install PyTorch 1.12.1 with CUDA 11.3
3. Install requirements (ftfy, regex, tqdm)
4. Clone and install dassl library
5. Verify installation

### Step 2: Run Experiments

```bash
conda activate badclip
bash RUN_EXPERIMENTS.sh
```

You'll see a menu:
```
1. Run BASELINE experiment (Learnable Trigger)
2. Run ABLATION experiment (Fixed Trigger)
3. Run BOTH experiments sequentially
4-7. Individual tests
8. Run ALL tests
9. Show results comparison
0. Run everything (train + test)
```

### Step 3: Quick Commands (Copy-Paste)

**Option A: Run everything automatically**
```bash
cd /data/junhoo/BadCLIP
conda activate badclip
bash RUN_EXPERIMENTS.sh
# Then press: 0 (to run complete pipeline)
```

**Option B: Run experiments separately**
```bash
cd /data/junhoo/BadCLIP
conda activate badclip

# Train baseline (learnable trigger)
bash scripts/badclip/imagenet_train_learnable.sh

# Train ablation (fixed trigger)
bash scripts/badclip/imagenet_train_fixed.sh

# Test learnable on seen classes
bash scripts/badclip/imagenet_test_learnable_seen.sh

# Test learnable on unseen classes
bash scripts/badclip/imagenet_test_learnable_unseen.sh

# Test fixed on seen classes
bash scripts/badclip/imagenet_test_fixed_seen.sh

# Test fixed on unseen classes
bash scripts/badclip/imagenet_test_fixed_unseen.sh
```

## Experimental Settings

- **Dataset**: ImageNet (located at `/data/imagenet`)
- **Backbone**: ViT-B/16
- **Few-shot**: 16-shot
- **Training**: Base classes (seen)
- **Testing**: Base classes (seen) + New classes (unseen)
- **Target class**: 0 (first class)
- **Epsilon**: 4.0
- **Epochs**: 10
- **Trigger**:
  - Learnable: Random initialization, optimized during training
  - Fixed: 4x4 white patch at position (220, 220)

## Results Location

All results are saved with the following structure:

### Training Results
```
output/imagenet_learnable/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/
├── log.txt                    # Training log with ACC and ASR
├── prompt_learner/
│   └── model-best.pth.tar    # Best prompt learner model
└── trigger/
    └── model-best.pth.tar    # Best trigger (or fixed pattern)

output/imagenet_fixed/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/
└── (same structure)
```

### Testing Results
```
output/test_learnable_seen/...    # Learnable trigger on seen classes
output/test_learnable_unseen/...  # Learnable trigger on unseen classes
output/test_fixed_seen/...        # Fixed trigger on seen classes
output/test_fixed_unseen/...      # Fixed trigger on unseen classes
```

## Understanding the Results

Look for these metrics in `log.txt`:

### Key Metrics

1. **ACC (Clean Accuracy)**: Performance on clean images
   - Higher is better
   - Measures utility of the model

2. **ASR (Attack Success Rate)**: Backdoor attack success
   - Percentage of triggered images classified as target class
   - Higher means better backdoor attack

### Expected Comparison

**Hypothesis**: Fixed trigger should have:
- Similar or slightly lower ACC (clean accuracy)
- Lower ASR (attack success rate) - because trigger is not optimized

**Files to check**:
```bash
# Training logs
cat output/imagenet_learnable/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt
cat output/imagenet_fixed/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt

# Test logs (seen)
cat output/test_learnable_seen/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt
cat output/test_fixed_seen/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt

# Test logs (unseen)
cat output/test_learnable_unseen/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt
cat output/test_fixed_unseen/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt
```

## Extracting Results

Create a simple script to extract metrics:

```bash
# Extract results
grep -E "accuracy|ASR" output/*/imagenet/shots_16/BadClip/*/seed1/log.txt
```

Or create a Python script:
```python
import os

results = {}
experiments = [
    ("Learnable-Train", "output/imagenet_learnable/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt"),
    ("Fixed-Train", "output/imagenet_fixed/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt"),
    ("Learnable-Seen", "output/test_learnable_seen/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt"),
    ("Fixed-Seen", "output/test_fixed_seen/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt"),
    ("Learnable-Unseen", "output/test_learnable_unseen/imagenet/shots_16/BadClip/vit_b16_imagenet_learnable_trigger/seed1/log.txt"),
    ("Fixed-Unseen", "output/test_fixed_unseen/imagenet/shots_16/BadClip/vit_b16_imagenet_fixed_trigger/seed1/log.txt"),
]

for name, log_path in experiments:
    if os.path.exists(log_path):
        with open(log_path, 'r') as f:
            content = f.read()
            # Extract accuracy and ASR
            print(f"\n{name}:")
            for line in content.split('\n'):
                if 'accuracy' in line.lower() or 'asr' in line.lower():
                    print(f"  {line}")
```

## Troubleshooting

### Environment Issues
```bash
# If conda environment creation fails
conda clean --all
bash setup_environment.sh

# If CUDA is not detected
python -c "import torch; print(torch.cuda.is_available())"
```

### Dataset Issues
```bash
# Verify ImageNet path
ls /data/imagenet

# Should contain: train/ val/ (or similar structure)
```

### Training Issues
```bash
# Check if GPU is available
nvidia-smi

# Monitor GPU usage during training
watch -n 1 nvidia-smi
```

## File Summary

### Modified Files
- `trainers/badclip.py` - Added learnable/fixed trigger support

### New Config Files
- `configs/trainers/BadClip/vit_b16_imagenet_learnable_trigger.yaml`
- `configs/trainers/BadClip/vit_b16_imagenet_fixed_trigger.yaml`

### New Scripts
- `setup_environment.sh` - Environment setup
- `RUN_EXPERIMENTS.sh` - Master execution script
- `scripts/badclip/imagenet_train_learnable.sh`
- `scripts/badclip/imagenet_train_fixed.sh`
- `scripts/badclip/imagenet_test_learnable_seen.sh`
- `scripts/badclip/imagenet_test_learnable_unseen.sh`
- `scripts/badclip/imagenet_test_fixed_seen.sh`
- `scripts/badclip/imagenet_test_fixed_unseen.sh`

## Technical Details

### Trigger Implementation

**Learnable Trigger** (Original):
```python
self.trigger = nn.Parameter(
    (torch.rand([1, 3, 224, 224]) - 0.5) * 2 * eps / std,
    requires_grad=True
)
```

**Fixed Trigger** (Ablation):
```python
trigger_pattern = torch.zeros([1, 3, 224, 224])
trigger_pattern[:, :, 220:224, 220:224] = 1.0  # 4x4 white patch
trigger_pattern = (trigger_pattern - mean) / std
self.register_buffer("trigger", trigger_pattern)
```

### Training Differences

| Aspect | Learnable | Fixed |
|--------|-----------|-------|
| Trigger Optimizer | Yes | No |
| Trigger Warm-up | Yes (3 epochs) | No |
| Trigger Updated | Yes | No |
| Parameters to Learn | Prompts + Trigger | Prompts only |

## Questions?

Check the original BadCLIP paper:
- Title: "BadCLIP: Trigger-Aware Prompt Learning for Backdoor Attacks on CLIP"
- Conference: CVPR 2024
- Code: https://github.com/KaiyangZhou/CoOp (CoOp baseline)
- Dassl: https://github.com/KaiyangZhou/Dassl.pytorch
