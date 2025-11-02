#!/usr/bin/env python
"""
Set CUDA_VISIBLE_DEVICES before importing torch
"""
import os

# Set CUDA_VISIBLE_DEVICES BEFORE importing torch
os.environ['CUDA_VISIBLE_DEVICES'] = '1,2,3,4,5,6,7'

print("=" * 60)
print("CUDA Test with Pre-Import Environment Setting")
print("=" * 60)
print(f"CUDA_VISIBLE_DEVICES set to: {os.environ['CUDA_VISIBLE_DEVICES']}")

import torch

print(f"\n✓ PyTorch version: {torch.__version__}")
print(f"✓ CUDA available: {torch.cuda.is_available()}")

if torch.cuda.is_available():
    print(f"✓ CUDA device count: {torch.cuda.device_count()}")
    for i in range(torch.cuda.device_count()):
        print(f"✓ GPU {i}: {torch.cuda.get_device_name(i)}")

    # Test tensor creation
    tensor = torch.randn(3, 3, device="cuda:0")
    print(f"✓ Tensor created on: {tensor.device}")
else:
    print("✗ CUDA not available")
