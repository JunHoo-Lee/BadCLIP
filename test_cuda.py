#!/usr/bin/env python
"""
CUDA debugging script to identify the issue
"""
import os
import sys

print("=" * 60)
print("CUDA Environment Debugging")
print("=" * 60)

# Check environment
print(f"\n1. Environment Variables:")
print(f"   CUDA_VISIBLE_DEVICES: {os.environ.get('CUDA_VISIBLE_DEVICES', 'Not set')}")
print(f"   CUDA_HOME: {os.environ.get('CUDA_HOME', 'Not set')}")

# Test 1: Import torch before CUDA
print(f"\n2. Importing torch...")
try:
    import torch
    print(f"   ✓ PyTorch version: {torch.__version__}")
    print(f"   ✓ CUDA compiled: {torch.version.cuda}")
except Exception as e:
    print(f"   ✗ Error importing torch: {e}")
    sys.exit(1)

# Test 2: Check CUDA availability
print(f"\n3. Checking CUDA availability...")
try:
    cuda_available = torch.cuda.is_available()
    print(f"   ✓ CUDA available: {cuda_available}")
    if cuda_available:
        print(f"   ✓ CUDA device count: {torch.cuda.device_count()}")
        for i in range(torch.cuda.device_count()):
            print(f"   ✓ GPU {i}: {torch.cuda.get_device_name(i)}")
    else:
        print(f"   ✗ CUDA not available!")
except Exception as e:
    print(f"   ✗ Error checking CUDA: {e}")

# Test 3: Try creating tensor on CUDA
print(f"\n4. Testing tensor creation on CUDA...")
try:
    if torch.cuda.is_available():
        device = torch.device("cuda:0")
        print(f"   ✓ Using device: {device}")
        tensor = torch.randn(3, 3, device=device)
        print(f"   ✓ Created tensor on GPU: {tensor.device}")
    else:
        print(f"   ⚠ Skipping (CUDA not available)")
except Exception as e:
    print(f"   ✗ Error creating tensor: {e}")

# Test 4: Test torch.as_tensor with device
print(f"\n5. Testing torch.as_tensor (the failing line)...")
try:
    if torch.cuda.is_available():
        test_list = [0.48145466, 0.4578275, 0.40821073]
        dtype = torch.float32

        # This is what's failing in the code
        tensor = torch.as_tensor(test_list, dtype=dtype, device="cuda")
        print(f"   ✓ torch.as_tensor with device='cuda' succeeded")
        print(f"   ✓ Result device: {tensor.device}")
    else:
        print(f"   ⚠ Skipping (CUDA not available)")
except Exception as e:
    print(f"   ✗ Error with torch.as_tensor: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 60)
print("Debugging complete!")
print("=" * 60)
